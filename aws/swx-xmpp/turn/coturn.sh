#!/bin/bash -x
LANG=C #needed for perl locale

# Discover public and private IP for this instance
PUBLIC_IPV4="${PUBLIC_IPV4:-$(curl --fail -qs whatismyip.akamai.com)}"
[ -n "$PUBLIC_IPV4" ] || PUBLIC_IPV4="$(curl -qs ipinfo.io/ip)"
[ -n "$PRIVATE_IPV4" ] || PRIVATE_IPV4="$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"

# Yes, this works. See: https://github.com/ianblenke/aws-6to4-docker-ipv6
#IPV6="$(ip -6 addr show eth0 | grep inet6 | grep global | awk '{print $2}')"

PORT=${PORT:-3478}
ALT_PORT=${PORT:-3479}

TLS_PORT=${TLS_PORT:-5349}
TLS_ALT_PORT=${TLS_ALT_PORT:-5350}

MIN_PORT=${MIN_PORT:-10000}
MAX_PORT=${MAX_PORT:-10999}

TURNSERVER_CONFIG=/app/etc/turnserver.conf

# https://github.com/coturn/coturn/blob/master/examples/etc/turnserver.conf
cat <<EOF > ${TURNSERVER_CONFIG}-template
listening-port=${PORT}
external-ip=${PUBLIC_IPV4}/${PRIVATE_IPV4}
min-port=${MIN_PORT}
max-port=${MAX_PORT}
EOF

if [ -n "${JSON_CONFIG}" ]; then
  echo "${JSON_CONFIG}" | jq -r '.config[]' >> ${TURNSERVER_CONFIG}-template
fi

enable_tls=0
if [ -n "$WILDCARD_SSL_CERTIFICATE" ]; then
  echo "$WILDCARD_SSL_CA_CHAIN" | base64 -d > /app/etc/turn_server_ca.pem
  echo "$WILDCARD_SSL_CERTIFICATE" | base64 -d  > /app/etc/turn_server_cert.pem
  echo "$WILDCARD_SSL_PRIVATE_KEY" | base64 -d  > /app/etc/turn_server_pkey.pem
  enable_tls=1
fi

if [ -f /ssl/acme.json ]; then
  jq -r .DomainsCertificate.Certs[0].Certificate.PrivateKey /ssl/acme.json   | base64 -d  > /app/etc/turn_server_pkey.pem
  jq -r .DomainsCertificate.Certs[0].Certificate.Certificate /ssl/acme.json   | base64 -d  > /app/etc/turn_server_cert.pem
  enable_tls=1
fi

if [ $enable_tls -eq 1 ] ; then
  cat <<EOT >> ${TURNSERVER_CONFIG}-template
tls-listening-port=${TLS_PORT}
alt-tls-listening-port=${TLS_ALT_PORT}
cert=/app/etc/turn_server_cert.pem
pkey=/app/etc/turn_server_pkey.pem
EOT
fi

if [ ! -f /app/etc/turn_server_ca.pem ] ; then
  (
    curl -sL https://letsencrypt.org/certs/isrgrootx1.pem.txt
    curl -sL https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt
    curl -sL https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt
    curl -sL https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.pem.txt
    curl -sL https://letsencrypt.org/certs/letsencryptauthorityx4.pem.txt
    curl -sL https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.pem.txt
    curl -sL https://letsencrypt.org/certs/letsencryptauthorityx2.pem.txt
    curl -sL https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem.txt
    curl -sL https://letsencrypt.org/certs/letsencryptauthorityx1.pem.txt
    curl -sL https://letsencrypt.org/certs/isrg-root-ocsp-x1.pem.txt
  ) > /app/etc/turn_server_ca.pem
fi

envsubst < ${TURNSERVER_CONFIG}-template > ${TURNSERVER_CONFIG}

cat ${TURNSERVER_CONFIG}

exec /app/bin/turnserver -l stdout --CA-file=/app/etc/turn_server_ca.pem
