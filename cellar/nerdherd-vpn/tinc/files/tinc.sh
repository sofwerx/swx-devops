#!/bin/bash
set -eo pipefail

HOSTNAME=$(echo ${HOSTNAME:-$(hostname)} | cut -d'.' -f1 | sed -e 's/-/_/g' )
NETNAME=${NETNAME:-tinc0}
DEBUG_LEVEL=${DEBUG_LEVEL:-3}
PIDFILE=/usr/var/run/tinc.${NETNAME}.pid
TINC=${TINC:-tinc --pidfile=${PIDFILE}}
START=${START:-${TINC} start -D -U nobody --logfile=/dev/stdout --debug=${DEBUG_LEVEL}}

TINC_PORT=${TINC_PORT:-655}

IP=${IP:-192.168.1.1}
SUBNET=${SUBNET:-255.255.255.0}

export PUBLIC_IP=${PUBLIC_IP:-$(curl -qs ipinfo.io/ip)}
export PRIVATE_IP=${PRIVATE_IP:-$(ip -o -4 route get 8.8.8.8 | cut -f8 -d' ')}

IPV6=${IPV6:-$(printf "2002:%02x%02x:%02x%02x::%02x%02x:%02x%02x/64" $(echo ${PUBLIC_IP} | tr "." " ") $(echo ${PRIVATE_IP} | tr "." " "))}

if [ -z "${HOSTNAME}" ] ; then echo "HOSTNAME not defined" ; false ; fi

mkdir -p /etc/tinc
cd /etc/tinc

echo "${NETNAME}">/etc/tinc/nets.boot

mkdir -p ${NETNAME}
cd ${NETNAME}

ls -la

if [ -f tinc.conf ] ; then
  cat tinc.conf
fi

# http://www.tinc-vpn.org/documentation-1.1/tinc.8

if [ ! -f /etc/tinc/${NETNAME}/tinc.conf ]; then
  ${TINC} init ${HOSTNAME}
fi

${TINC} set Port ${TINC_PORT}
if [ -n "${TINC_ADDRESS_FAMILY}" ]; then ${TINC} set AddressFamily ${TINC_ADDRESS_FAMILY} ; fi
${TINC} set AutoConnect ${TINC_AUTO_CONNECT:-yes}
if [ -n "${TINC_BIND_TO_INTERFACE}" ]; then ${TINC} set BindToInterface ${TINC_BIND_TO_INTERFACE} ; fi
${TINC} set Broadcast ${TINC_BROADCAST:-mst}
if [ -n "${TINC_BROADCAST_SUBNET}" ]; then ${TINC} set BroadcastSubnet ${TINC_BROADCAST_SUBNET} ; fi
if [ -n "${TINC_CONNECT_TO}" ]; then ${TINC} set ConnectTo ${TINC_CONNECT_TO} ; fi
if [ -n "${TINC_DECREMENT_TTL}" ]; then ${TINC} set DecrementTTL ${TINC_DECREMENT_TTL} ; fi
if [ -n "${TINC_DEVICE}" ]; then ${TINC} set Device ${TINC_DEVICE} ; fi
${TINC} set DeviceStandby = ${TINC_DEVICE_STANDBY:-yes}
if [ -n "${TINC_DEVICE_TYPE}" ]; then ${TINC} set DeviceType ${TINC_DEVICE_TYPE} ; fi
if [ -n "${TINC_DIRECT_ONLY}" ]; then ${TINC} set DirectOnly ${TINC_DIRECT_ONLY} ; fi
${TINC} set Ed25519PrivateKeyFile ${TINC_ED_25519_PRIVATE_KEY_FILE:-/etc/tinc/${NETNAME}/ed25519_key.priv}
${TINC} set ExperimentalProtocol ${TINC_EXPERIMENTAL_PROTOCOL:-yes}
if [ -n "${TINC_FORWARDING}" ]; then ${TINC} set Forwarding ${TINC_FORWARDING} ; fi
if [ -n "${TINC_HOSTNAMES}" ]; then ${TINC} set Hostnames ${TINC_HOSTNAMES} ; fi
if [ -n "${TINC_INTERFACE}" ]; then ${TINC} set Interface ${TINC_INTERFACE} ; fi
${TINC} set KeyExpire ${TINC_KEY_EXPIRE:-3600}
if [ -n "${TINC_LISTEN_ADDRESS}" ]; then ${TINC} set ListenAddress ${TINC_LISTEN_ADDRESS} ; fi
${TINC} set LocalDiscovery ${TINC_LOCAL_DISCOVERY:-no}
if [ -n "${TINC_LOCAL_DISCOVERY_ADDRESS}" ]; then ${TINC} set LocalDiscoveryAddress ${TINC_LOCAL_DISCOVERY_ADDRESS} ; fi
${TINC} set MACExpire ${TINC_MAC_EXPIRE:-600}
${TINC} set MaxConnectionBurst ${TINC_MAX_CONNECTION_BURST:-100}
${TINC} set Mode ${TINC_MODE:-switch}
${TINC} set PingInterval ${TINC_PING_INTERVAL:-60}
${TINC} set PingTimeout ${TINC_PING_TIMEOUT:-5}
if [ -n "${TINC_PRIORITY_INHERITANCE}" ]; then ${TINC} set PriorityInheritance ${TINC_PRIORITY_INHERITANCE} ; fi
if [ -n "${TINC_PRIVATE_KEY}" ]; then ${TINC} set PrivateKey ${TINC_PRIVATE_KEY} ; fi
${TINC} set PrivateKeyFile ${TINC_PRIVATE_KEY_FILE:-/etc/tinc/${NETNAME}/rsa_key.priv}
${TINC} set ProcessPriority ${TINC_PROCESS_PRIORITY:-normal}
if [ -n "${TINC_PROXY}" ]; then ${TINC} set Proxy ${TINC_PROXY} ; fi
${TINC} set ReplayWindow ${TINC_REPLAY_WINDOW:-16}
if [ -n "${TINC_STRICT_SUBNETS}" ]; then ${TINC} set StrictSubnets ${TINC_STRICT_SUBNETS} ; fi
${TINC} set TunnelServer ${TINC_TUNNEL_SERVER:-no}
if [ -n "${TINC_UDP_RCV_BUF}" ]; then ${TINC} set UDPRcvBuf ${TINC_UDP_RCV_BUF} ; fi
if [ -n "${TINC_UDP_SND_BUF}" ]; then ${TINC} set UDPSndBuf ${TINC_UDP_SND_BUF} ; fi

mkdir -p hosts

${TINC} export

#PRIVATE_INTERFACE=${PRIVATE_INTERFACE:-eth1}
BRIDGE_INTERFACE=${BRIDGE_INTERFACE:-br${NETNAME}}

cat << TINCUP > tinc-up
#!/bin/bash -x
brctl addbr ${BRIDGE_INTERFACE} || true
ifconfig ${BRIDGE_INTERFACE} up
if [ -n "${PRIVATE_INTERFACE}" ]; then
  brctl addif ${BRIDGE_INTERFACE} ${PRIVATE_INTERFACE} || true
  ifconfig ${PRIVATE_INTERFACE} up
fi
brctl addif ${BRIDGE_INTERFACE} \${INTERFACE} || true
ifconfig \${INTERFACE} up
ip -6 addr add ${IPV6} dev ${BRIDGE_INTERFACE}
TINCUP
chmod u+x tinc-up

cat << TINCDOWN > tinc-down
#!/bin/bash -x
ip -6 addr del ${IPV6} dev ${BRIDGE_INTERFACE} || true
ifconfig \${INTERFACE} down
brctl delif ${BRIDGE_INTERFACE} \${INTERFACE} || true
if [ -n "${PRIVATE_INTERFACE}" ]; then
  ifconfig ${PRIVATE_INTERFACE} down
  brctl delif ${BRIDGE_INTERFACE} ${PRIVATE_INTERFACE} || true
fi
ifconfig ${BRIDGE_INTERFACE} down
brctl delbr ${BRIDGE_INTERFACE} || true
TINCDOWN
chmod u+x tinc-down

# If CONSUL_VERSION is defined, prepare and run a consul agent

if [ -n "${CONSUL_VERSION}" ]; then
  CONSUL_VERSION=${CONSUL_VERSION:-0.5.2}

  export CONSUL_SERVICE_NAME=${CONSUL_SERVICE_NAME:-tinc}
  export CONSUL_SERVICE_PORT=${CONSUL_SERVICE_PORT:-${TINC_PORT}}

  apk add --update ca-certificates bash wget curl rsync unzip jq

  curl -sLo /tmp/glibc-2.21-r2.apk https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk
  apk add --update --allow-untrusted /tmp/glibc-2.21-r2.apk
  rm -rf /tmp/glibc-2.21-r2.apk

  curl -sLo /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
  curl -sLo /tmp/consul.sha256sums https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS
  echo "$(grep consul_${CONSUL_VERSION}_linux_amd64.zip /tmp/consul.sha256sums | awk '{print $1}')  /tmp/consul.zip" > /tmp/consul.sha256
  cat /tmp/consul.sha256
  sha256sum /tmp/consul.zip
  sha256sum -c /tmp/consul.sha256 || (echo "$0: consul.zip failed SHA checksum"; exit 1)
  unzip -o /tmp/consul.zip -d /usr/bin
  chmod +x /usr/bin/consul
  mkdir -p {/data/consul,/etc/consul/conf.d,/etc/consul/handlers.d}
  rm /tmp/consul.zip
  rm -rf /var/cache/apk/*

  # Install goreman - foreman clone written in Go language
  curl -sLo /tmp/goreman.tar.gz https://github.com/mattn/goreman/releases/download/v0.0.7/goreman_linux_amd64.tar.gz
  tar xvzf /tmp/goreman.tar.gz -C /usr/local/bin --strip-components=1

  # Start a consul session, and ensure cleanup on tinc-down
  export CONSUL_SESSION_ID=$(curl  -X PUT -d '{"Name": "tinc-session","Behavior": "delete"}' http://${CONSUL_HOST:-172.17.0.1}:8500/v1/session/create | jq -r .ID)
  echo "curl  -X PUT http://${CONSUL_HOST:-172.17.0.1}:8500/v1/session/destroy/${CONSUL_SESSION_ID}" >> tinc-down

  hash -r

  # Fire consul events for the tinc scripts
  echo 'consul event -name tinc/v1.1/host-up "$(${TINC} export)"' >> tinc-up
  echo 'consul event -name tinc/v1.1/host-down "$(${TINC} export)"' >> tinc-down

  cat <<PROCFILE > /Procfile
tinc: ${START}
consul: /consul_agent.sh
PROCFILE

  START="/usr/local/bin/goreman -f /Procfile start"
  export GOMAXPROCS=2
fi

exec ${START}
