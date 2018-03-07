#!/bin/bash

gen_key() {
  keytype=$1
  ks="${keytype}_"
  key="${TMATE_KEYS_DIR}/ssh_host_${ks}key"
  if [ ! -e "${key}" ] ; then
    if ssh-keygen --help 2>&1 | grep -e '-E ' > /dev/null; then
      ssh-keygen -t ${keytype} -f "${key}" -N '' -E md5
    else
      ssh-keygen -t ${keytype} -f "${key}" -N ''
    fi
    return $?
  fi
}

gen_key rsa
gen_key ecdsa

TMATE_RSA_FINGERPRINT=$(ssh-keygen -lf "${TMATE_KEYS_DIR}/ssh_host_rsa_key" -E md5 | awk '{print $2}' | sed -e 's/^MD5://')
TMATE_ECDSA_FINGERPRINT=$(ssh-keygen -lf "${TMATE_KEYS_DIR}/ssh_host_ecdsa_key"  -E md5 | awk '{print $2}' | sed -e 's/^MD5://')

cat <<EOM
# In order to use this tmate server, configure your tmate config as follows:

cat <<EOF > ~/.tmate.conf
set -g tmate-server-host "${TMATE_HOST}"
set -g tmate-server-port ${TMATE_PORT}
set -g tmate-server-rsa-fingerprint   "${TMATE_RSA_FINGERPRINT}"
set -g tmate-server-ecdsa-fingerprint "${TMATE_ECDSA_FINGERPRINT}"
set -g tmate-identity ""              # Can be specified to use a different SSH key.
EOF

EOM

exec ./tmate-slave
