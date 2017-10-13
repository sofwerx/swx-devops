#!/bin/bash - 
set -Eeuo pipefail

CONFIG=${PWD}/bitmonero.conf

# RPC_BIND_IP=$(ip addr show eth0 | grep inet | cut -d/ -f1 | awk '{print $2}')

cat <<EOF > $CONFIG
# change this in your own container!
# TODO: set this automatically in the entrypoint
#rpc-login=${MONERO_USERNAME:-monero}:${MONERO_PASSWORD:-changeme}

# for Tor
p2p-bind-ip=${P2P_BIND_IP:-0.0.0.0}
no-igd=${NO_IGD:-true}

# for external wallets
rpc-bind-ip=${RPC_BIND_IP:-0.0.0.0}
confirm-external-bind=${CONFIRM_EXTERNAL_BIND:-true}
restricted-rpc=${RESTRICTED_RPC:-false}
EOF

export TORSOCKS_CONF_FILE=/etc/tor/torsocks.conf

# make monero work with Tor
# https://github.com/monero-project/monero/blob/master/README.md#using-tor
export DNS_PUBLIC=tcp
export TORSOCKS_ALLOW_INBOUND=1

# Warn if the DOCKER_HOST socket does not exist
if [[ $DOCKER_HOST == unix://* ]]; then
	socket_file=${DOCKER_HOST#unix://}
	if ! [ -S $socket_file ]; then
		cat >&2 <<-EOT
			ERROR: you need to share your Docker host socket with a volume at $socket_file
			Typically you should run your jheretic/onionboat with: \`-v /var/run/docker.sock:$socket_file:ro\`
			See the documentation at https://git.io/voqk1
		EOT
		socketMissing=1
	fi
fi

# If the user has run the default command and the socket doesn't exist, fail
if [ "${socketMissing:-0}" = 1 -a "$1" = '/usr/bin/supervisord' -a "$2" = '-c' -a "$3" = '/etc/supervisor/supervisord.conf' ]; then
	exit 1
fi

(
  # Capture the current environment
  env
  # torify everything
  echo LD_PRELOAD=/usr/lib/x86_64-linux-gnu/torsocks/libtorsocks.so
) | grep -v affinity:container | xargs -l1 -i% echo export '"%"' > ~/monero.env

exec "$@"
