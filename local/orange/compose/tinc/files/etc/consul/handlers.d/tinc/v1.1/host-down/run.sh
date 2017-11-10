#!/bin/bash -xe
# This event fires when a node leaves

# Variables:
# $@ - Decoded Payload

export NETNAME=${NETNAME:-$(tail -1 /etc/tinc/nets.boot)}
PIDFILE=/usr/var/run/tinc.${NETNAME}.pid
TINC=${TINC:-tinc --pidfile=${PIDFILE}}

# Forget about old nodes
${TINC} purge

