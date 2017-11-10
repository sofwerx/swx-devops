#!/bin/bash

DNS_DOMAIN=${DNS_DOMAIN:-docker.local}
HTTP_PORT=${HTTP_PORT:-8080}

mkdir -p /etc/traefik
mkdir -p /ssl
cat <<EOF > /etc/traefik/traefik.toml
logLevel = "DEBUG"
################################################################
# Web configuration backend
################################################################
[web]
address = ":${REST_PORT}"
################################################################
# Docker configuration backend
################################################################
[docker]
endpoint = "unix:///var/run/docker.sock"
domain = "${DNS_DOMAIN}"
watch = true
# Sample entrypoint configuration when using ACME
[entryPoints]
  [entryPoints.http]
  address = ":${HTTP_PORT}"
#    [entryPoints.http.redirect]
#    entryPoint = "https"
  [entryPoints.https]
  address = ":${HTTPS_PORT}"
    [entryPoints.https.tls]
EOF

if [ -n "${WILDCARD_SSL_CERTIFICATE}" ]; then

  mkdir -p /etc/traefik/tls

  if [ -n "${WILDCARD_SSL_PRIVATE_KEY}" ]; then
    echo ${WILDCARD_SSL_PRIVATE_KEY} | base64 -d > /etc/traefik/tls/wildcard_ssl_private_key.pem
  fi
  if [ -n "${WILDCARD_SSL_CERTIFICATE}" ]; then
    echo ${WILDCARD_SSL_CERTIFICATE} | base64 -d > /etc/traefik/tls/wildcard_ssl_certificate.pem
    echo ${WILDCARD_SSL_CA_CHAIN} | base64 -d > /etc/traefik/tls/wildcard_ssl_certificate_and_ca_chain.pem
  fi
  if [ -n "${WILDCARD_SSL_CA_CHAIN}" ]; then
    echo ${WILDCARD_SSL_CA_CHAIN} | base64 -d > /etc/traefik/tls/wildcard_ssl_ca_chain.pem
    echo ${WILDCARD_SSL_CA_CHAIN} | base64 -d >> /etc/traefik/tls/wildcard_ssl_certificate_and_ca_chain.pem
  fi

  cat <<EOF >> /etc/traefik/traefik.toml
      [[entryPoints.https.tls.certificates]]
      CertFile = "/etc/traefik/tls/wildcard_ssl_certificate.pem"
      KeyFile = "/etc/traefik/tls/wildcard_ssl_private_key.pem"
EOF

else

cat <<EOF >> /etc/traefik/traefik.toml
# Enable ACME (Let's Encrypt): automatic SSL
#
# Optional
#
[acme]

# Email address used for registration
#
# Required
#
email = "${EMAIL}"

# File used for certificates storage.
# WARNING, if you use Traefik in Docker, don't forget to mount this file as a volume.
#
# Required
#
storageFile = "/ssl/acme.json"

# Entrypoint to proxy acme challenge to.
# WARNING, must point to an entrypoint on port 443
#
# Required
#
entryPoint = "https"

# Enable on demand certificate. This will request a certificate from Let's Encrypt during the first TLS handshake for a hostname that does not yet have a certificate.
# WARNING, TLS handshakes will be slow when requesting a hostname certificate for the first time, this can leads to DoS attacks.
# WARNING, Take note that Let's Encrypt have rate limiting: https://community.letsencrypt.org/t/quick-start-guide/1631
#
# Optional
#
onDemand = true

# CA server to use
# Uncomment the line to run on the staging let's encrypt server
# Leave comment to go to prod
#
# Optional
#
caServer = "https://acme-staging.api.letsencrypt.org/directory"

# Domains list
# You can provide SANs (alternative domains) to each main domain
# All domains must have A/AAAA records pointing to Traefik
# WARNING, Take note that Let's Encrypt have rate limiting: https://community.letsencrypt.org/t/quick-start-guide/1631
# Each domain & SANs will lead to a certificate request.
#
# [[acme.domains]]
#   main = "local1.com"
#   sans = ["test1.local1.com", "test2.local1.com"]
# [[acme.domains]]
#   main = "local2.com"
#   sans = ["test1.local2.com", "test2x.local2.com"]
# [[acme.domains]]
#   main = "local3.com"
# [[acme.domains]]
#   main = "local4.com"
[[acme.domains]]
  main = "${DNS_DOMAIN}"
  sans = [ ${SUBDOMAINS} ]
EOF

fi # $WILDCARD_SSL_CERTIFICATE

cat /etc/traefik/traefik.toml

exec /go/bin/traefik $@
