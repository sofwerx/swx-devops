#!/bin/bash -x

mkdir -p /tmp/secrets
chmod 700 /tmp/secrets

export SSL_KEY=${SSL_KEY:-/tmp/secrets/ssl_private.key}
export SSL_CERT=${SSL_CERT:-/tmp/secrets/ssl_private.crt}

if [ -f /ssl/acme.json ] ; then
  fqdn="$(jq -r '.DomainsCertificate[] | .[].Certificate.Domain' /ssl/acme.json | grep jupyterhub)"
  jq -r ".DomainsCertificate[] | .[] | select(.Certificate.Domain==\"$fqdn\") | .Certificate.PrivateKey" /ssl/acme.json | base64 -d > ${SSL_KEY}
  jq -r ".DomainsCertificate[] | .[] | select(.Certificate.Domain==\"$fqdn\") | .Certificate.Certificate" /ssl/acme.json | base64 -d > ${SSL_CERT}
fi

chmod 600 ${SSL_KEY} ${SSL_CERT}

touch /srv/jupyterhub/userlist

for user in $(echo ${GITHUB_USERLIST:-ianblenke+admin} | sed -e 's/,/ /g') ; do
  echo $user | sed -e 's/+/ /' >> /srv/jupyterhub/userlist
done

exec jupyterhub -f /srv/jupyterhub/jupyterhub_config.py --debug $@
