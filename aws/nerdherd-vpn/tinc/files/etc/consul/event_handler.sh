#!/bin/bash -e

##############################################################################
#
# event_handler.sh
#
# Main Event Handler Script
#
# Receives all events via Consul watchers
#
# WARNING: *ASSUME* THIS CODE NEEDS TO RUN ON MULTIPLE LINUX DISTRIBUTIONS
# (I.E. NO "APT-GET", "YUM", "APK" WITHOUT A TEST BLOCK)
#
##############################################################################

trap clean_up 1 2 3 4 5 6 7 8 10 11 12 13 14 15 16 17 18 19 20

CONSUL_STATUS=/var/consul/status
if [ ! -d CONSUL_STATUS ] ; then mkdir -p $CONSUL_STATUS; fi

CONSUL_TMP=/var/consul/tmp
if [ ! -d CONSUL_TMP ] ; then mkdir -p $CONSUL_TMP; fi

CONSUL_HANDLERS=/etc/consul/handlers.d
if [ ! -d $CONSUL_HANDLERS ] ; then echo "*** No Consul Event Handlers Defined! ***" ; exit 99; fi

export TMP=$(mktemp /var/consul/tmp/agentXXXXXX)

##############################################################################
#
# clean_up()
#
# Removes TMP files and the like upon exit or explosion of script
#
##############################################################################
function clean_up {
  echo rm -f $TMP
  exit 0
}


##############################################################################
#
# Receive the Event
# Determine if the EventType is configured on the agent (i.e. is there a handlers.d/APP/v?/EventType/run.sh)
# Determine if the Event has been processed already (check for /var/consul/eh/{Event->ID} touch file)
# If not already processed, fire off the specific EventType handler in a subshell (i.e. do not block main Event Handler processing loop)
#   If successful completion, touch /var/consul/eh/{Event->ID} touch file, or insert timestamp or something
#   If NOT successful, how do we handle error correction and recovery?  Retry X times, raise some sort of Error Event for the Master Consul server to email/page/scream?
# Need to check for children processes still running before exiting the main Event Handler process
#
##############################################################################


##############################################################################
#
# Main loop
#
##############################################################################

# Get the event JSON into a TMP file
while read ALINE; do echo $ALINE>>$TMP; done

# Get the Event Type
EVENT_NAME=$(cat $TMP | jq -r .[].Name)

# Check for NULL event
if [ -z "$EVENT_NAME" ] ; then clean_up; fi

# Get the ID of the Event
ID=$(cat $TMP | jq -r .[].ID)

# Get the Payload (JSON) of the Event
PAYLOAD=$(cat $TMP | jq -r .[].Payload | base64 -d)

# Get the TimeStamp (seconds from Epoch) from the Payload
TS=$(echo $PAYLOAD | jq -r .TimeStamp)

echo "received $EVENT_NAME ($ID) at $(date -d $TS) with Payload: "
#echo "received $EVENT_NAME ($ID) with Payload: "
echo "$(echo $PAYLOAD | jq .)"

##############################################################################
#
# Executes the specific EventHandler script in a subshell.
#
# Marks when event completes successfully, or sends Alert if problem
#
##############################################################################
if [ -x $CONSUL_HANDLERS/$EVENT_NAME/run.sh ] ; then

  # Stuff the Payload into a tmp file to pass to the EventHandler
  PAYLOAD_TMP=$(mktemp /var/consul/tmp/payloadXXXXXX)
  echo $PAYLOAD | jq . >$PAYLOAD_TMP

  $CONSUL_HANDLERS/$EVENT_NAME/run.sh $PAYLOAD_TMP
  rc=$?

  if [ $rc = 0 ] ; then
    cp $TMP $CONSUL_STATUS/
  else
    echo "*** Something went wrong ***"
    exit 1
  fi
fi

clean_up
