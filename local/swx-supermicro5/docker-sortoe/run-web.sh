#!/bin/bash
mkdir -p /etc/nginx/html/config
cat <<EOF > /etc/nginx/html/config/server.js
configs = {
 SORTOE_API_URL: "${SORTOE_API_URL}",
 SORTOE_API_VERSION: "${SORTOE_API_VERSION}",
 SORTOE_DATASERVICE_HOST: "${SORTOE_DATASERVICE_HOST}",
 SORTOE_GRAPHQL_URL: "${SORTOE_GRAPHQL_URL}"
};
EOF
exec nginx -g 'daemon off;'
