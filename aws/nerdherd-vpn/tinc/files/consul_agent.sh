#!/bin/bash

export TINC_PORT=${TINC_PORT:-655}

export CONSUL_SERVICE_NAME="tinc"
export CONSUL_SERVICE_PORT="${TINC_PORT}"

export PRIVATE_IP=$(ip a s eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
export PUBLIC_IP=$(curl -qs ipinfo.io/ip)

env | grep CONSUL

envsubst < /etc/consul/conf.d/tinc.json-template > /etc/consul/conf.d/tinc.json

cat <<CONFIG > client_config.json
{
    "node": "${CONSUL_SERVICE_NAME}",
    "server": false,
    "ui": true,
    "leave_on_terminate": true,
    "rejoin_after_leave": true,
    "advertise_addrs": {
      "serf_lan": "${PRIVATE_IP}:18301",
      "serf_wan": "${PUBLIC_IP}:18302",
      "rpc": "${PRIVATE_IP}:18400"
    },
    "client_addr": "${PRIVATE_IP}",
    "ports": {
        "dns": 18600,
        "http": 18500,
        "https": -1,
        "rpc": 18400,
        "serf_wan": 18302,
        "serf_lan": 18301,
        "server: 18300
    },
    "data_dir": "/data/consul",
    "config_dir": "/etc/consul/conf.d",
    "start_join": [ "${CONSUL_HOST:-172.17.0.1}" ]
    "log_level": "INFO",
    "disable_remote_exec": false
}
CONFIG

exec consul agent -config-file client_config.json 
