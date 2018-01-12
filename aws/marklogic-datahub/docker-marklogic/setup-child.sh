#!/bin/bash
####################################################################
# This script will join a MarkLogic server to a cluster
# running inside a docker container
####################################################################
JOINING_HOST=`hostname`
BOOTSTRAP_HOST="$1"
CONFIG_FILE="${2}"
SKIP=0
RETRY_INTERVAL=5
N_RETRY=10
BOOTSTRAP_HOST_STATUS=""
JOINING_HOST_ENC="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$JOINING_HOST")"
source $CONFIG_FILE
CURL="curl -s -S"
AUTH_CURL="${CURL} --${AUTH_MODE} --user ${USER}:${PASSWORD}"
function restart_check {
  echo "Restart check for $1..."
  LAST_START=`$AUTH_CURL --max-time 1 -s "http://localhost:8001/admin/v1/timestamp"`
  echo "LAST_START: ${LAST_START}"
  for i in `seq 1 ${N_RETRY}`; do
    # continue as long as timestamp didn't change, or no output was returned
    if [ "$2" == "$LAST_START" ] || [ "$LAST_START" == "" ]; then
      sleep ${RETRY_INTERVAL}
      echo "Retrying..."
      LAST_START=`$AUTH_CURL --max-time 1 -s "http://localhost:8001/admin/v1/timestamp"`
      echo "LAST_START: ${LAST_START}"
    else
      return 0
    fi
  done
  echo "ERROR: Line $3: Failed to restart $1"
  exit 1
}
function node_available_check {
  $CURL --max-time 1 -s -o "host_status.html" "http://$BOOTSTRAP_HOST:7997"
  BOOTSTRAP_HOST_STATUS=`grep "Healthy" host_status.html`
  for i in `seq 1 ${N_RETRY}`; do
    # continue until status is healthy or max tries is reached
    if [ "" == "${BOOTSTRAP_HOST_STATUS}" ] || [ "Healthy" != "${BOOTSTRAP_HOST_STATUS}" ]; then
        sleep ${RETRY_INTERVAL}
        echo "Retrying..."
    $CURL --max-time 1 -s -o "host_status.html" "http://$BOOTSTRAP_HOST:7997"
    BOOTSTRAP_HOST_STATUS=`grep "Healthy" host_status.html`
    else
      return 0
    fi
  done
  echo "ERROR: Line $1: Failed to get $BOOTSTRAP_HOST healthy status"
  exit 1
}
echo "Verifying $BOOTSTRAP_HOST is available to join..."
## Verify host is available to join with
node_available_check $LINENO
if [ $? -ne 0 ]; then
  echo "Unable to verify ${1} is available after ${N_RETRY} attempts. Aborting script!"
  exit 1
fi
# (1) Initialize MarkLogic Server on the joining host
echo "Initializing MarkLogic server ..."
TIMESTAMP=`$CURL -X POST -d "" \
 http://${JOINING_HOST}:8001/admin/v1/init \
  | grep "last-startup" \
  | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`
if [ "$TIMESTAMP" == "" ]; then
  echo "ERROR: Failed to initialize $JOINING_HOST" >&2
  exit 1
fi
restart_check $JOINING_HOST $TIMESTAMP $LINENO
echo "Retrieve $JOINING_HOST configuration..."
# (2) Retrieve the joining host's configuration
JOINER_CONFIG=`$CURL -X GET -H "Accept: application/xml" http://${JOINING_HOST}:8001/admin/v1/server-config`
echo $JOINER_CONFIG | grep -q "^<host"
if [ "$?" -ne 0 ]; then
  echo "ERROR: Failed to fetch server config for $JOINING_HOST"
  SKIP=1
fi
if [ "$SKIP" -ne 1 ]; then
  echo "Send $JOINING_HOST configuration to the bootstrap host $BOOTSTRAP_HOST ..."
  # (3) Send the joining host's config to the bootstrap host, receive
  #     the cluster config data needed to complete the join. Save the
  #     response data to cluster-config.zip.
  # Backwards-compat with old curl
  JOINER_CONFIG_ENC="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$JOINER_CONFIG")"
  $AUTH_CURL -X POST -o cluster-config.zip --data "group=Default" \
             --data "server-config=${JOINER_CONFIG_ENC}" \
             -H "Content-type: application/x-www-form-urlencoded" \
             http://${BOOTSTRAP_HOST}:8001/admin/v1/cluster-config
  if [ "$?" -ne 0 ]; then
    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST"
    exit 1
  fi
  if [ `file cluster-config.zip | grep -cvi "zip archive data"` -eq 1 ]; then
    echo "ERROR: Failed to fetch cluster config from $BOOTSTRAP_HOST"
    exit 1
  fi
  echo "Send the cluster config data to the joining host $JOINING_HOST, completing the join sequence..."
  # (4) Send the cluster config data to the joining host, completing 
  #     the join sequence.
  TIMESTAMP=`$CURL -X POST -H "Content-type: application/zip" \
                   --data-binary @./cluster-config.zip \
                   http://${JOINING_HOST}:8001/admin/v1/cluster-config \
                   | grep "last-startup" \
                   | sed 's%^.*<last-startup.*>\(.*\)</last-startup>.*$%\1%'`
    
  echo "Restart check $JOINING_HOST $TIMESTAMP ..."
  restart_check $JOINING_HOST $TIMESTAMP $LINENO
  rm ./cluster-config.zip
  echo "...$JOINING_HOST successfully added to the cluster."
fi
echo "Removing network suffix from hostname"
$AUTH_CURL -o "hosts.html" -X GET "http://${JOINING_HOST}:8001/host-summary.xqy?section=host"
HOST_URL=`grep "statusfirstcell" hosts.html \
  | grep ${JOINING_HOST} \
  | sed 's%^.*href="\(host-admin.xqy?section=host&host=[^"]*\)".*$%\1%'`
HOST_ID=`grep "statusfirstcell" hosts.html \
  | grep ${JOINING_HOST} \
  | sed 's%^.*href="host-admin.xqy?section=host&host=\([^"]*\)".*$%\1%'`
echo "HOST_URL is $HOST_URL"
echo "HOST_ID is $HOST_ID"
$AUTH_CURL -o "host.html" -X GET "http://${JOINING_HOST}:8001/$HOST_URL"
HOST_XPATH=`grep host-name host.html \
  | grep input \
  | sed 's%^.*name="\([^"]*\)".*$%\1%'`
echo "HOST_XPATH is $HOST_XPATH"
# Backwards-compat with old curl
HOST_ID_ENC="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "$HOST_ID")"
$AUTH_CURL -X POST \
           --data "host=$HOST_ID_ENC" \
           --data "section=host" \
           --data "$HOST_XPATH=${JOINING_HOST_ENC}.ml-service" \
           --data "ok=ok" \
           "http://${JOINING_HOST}:8001/host-admin-go.xqy"
/sbin/service MarkLogic restart
echo "Waiting for server restart.."
sleep 5
echo "$JOINING_HOST initialized and joined to cluster..."
rm *.html
