#!/bin/bash
mkdir -p /etc/nginx/html/config
cat <<EOF > /etc/nginx/html/config/server.js
configs = {
 SORTOE_API_URL: "${SORTOE_API_URL}",
 SORTOE_API_VERSION: "${SORTOE_API_VERSION}",
 SORTOE_DATASERVICE_HOST: "sortoe.${DNS_DOMAIN}",
 SORTOE_GRAPHQL_URL: "https://sortoe.${DNS_DOMAIN}/v1.0.0/graphiql"
};
EOF
exec nginx -g 'daemon off;'
