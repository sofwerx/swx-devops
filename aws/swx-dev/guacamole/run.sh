#!/bin/bash

cat <<EOF > ~/.pgpass
${POSTGRES_HOSTNAME:-postgres}:${POSTGRES_PORT:-5432}:${POSTGRES_DATABASE:-postgres}:${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}
EOF
chmod 600 ~/.pgpass

export PGPASSWORD=${POSTGRES_PASSWORD}

if [ ! -f /data/.postgres.initialized ]; then
  createdb -h ${POSTGRES_HOSTNAME:-postgres} -U ${POSTGRES_USER:-postgres} -p ${POSTGRES_PORT:-5432} guacamole
  /opt/guacamole/bin/initdb.sh --postgres | psql -h ${POSTGRES_HOSTNAME:-postgres} -U ${POSTGRES_USER:-postgres} -p ${POSTGRES_PORT:-5432} guacamole
  touch /data/.postgres.initialized
fi

export POSTGRES_DATABASE=guacamole

exec /opt/guacamole/bin/start.sh
