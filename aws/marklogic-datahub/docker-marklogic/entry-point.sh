#!/bin/bash
####################################################################
# This script provides an entry point for setting up master and child
# MarkLogic nodes and keeping service running
####################################################################
CONFIGURATION_FILE_LOCATION='/opt/mlconfig.sh'
HOST_NAME=`hostname`
# SIGTERM-handler
function term_handler {
  echo "Shutting down MarkLogic instance..."
  /etc/init.d/MarkLogic stop
  sleep 3
  exit 0;
}
echo "Starting MarkLogic..."
/etc/init.d/MarkLogic start
sleep 3
trap term_handler SIGTERM SIGINT
# If an alternate configuration file is passed in then use that
if [ ! -z "$2" ]; then
  CONFIGURATION_FILE_LOCATION=$2
fi
if [[ "${HOST_NAME}" == "datahub-0"* ]]; then
  echo "Setting up Master Node"
  ./setup-master.sh $CONFIGURATION_FILE_LOCATION
else
  echo "Setting up Child Node"
  # NOTE - The datahub-0.ml-service will have to account for real DNS entries
  ./setup-child.sh "datahub-0.ml-service.default.svc.cluster.local" $CONFIGURATION_FILE_LOCATION
fi
# Do nothing loop to keep script active so it can intercept the container stop signal to shut down MarkLogic
while true; do sleep 1; done
