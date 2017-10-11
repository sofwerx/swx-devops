#!/bin/bash

mkdir -p /ssl /etc/ssl/private /etc/ssl/certs

SSL=""
SECURE=false
if [ -f /ssl/acme.json ]; then
  SECURE=true
  jq -r .DomainsCertificate.Certs[0].Certificate.PrivateKey /ssl/acme.json   | base64 -d  > /etc/ssl/private/guacd.key
  jq -r .DomainsCertificate.Certs[0].Certificate.Certificate /ssl/acme.json   | base64 -d  > /etc/ssl/certs/guacd.crt

  SSL="-C /etc/ssl/certs/guacd.crt -K /etc/ssl/private/guacd.key"
fi

exec /usr/local/sbin/guacd -b 0.0.0.0 -f ${SSL}

