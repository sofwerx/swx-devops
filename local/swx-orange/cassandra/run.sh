#!/bin/bash
export CASSANDRA_LISTEN_ADDRESS=$(ip addr show | grep 'inet 192.168.1' | cut -d/ -f1 | awk '{print $2}')
export CASSANDRA_RPC_ADDRESS=${CASSANDRA_LISTEN_ADDRESS}
export CASSANDRA_BROADCAST_ADDRESS=${CASSANDRA_LISTEN_ADDRESS}
exec cassandra -f -R $@
