#!/bin/bash

REPLACE_WILDCARDS="${REPLACE_WILDCARDS:-yes}"
SERVICE_FILENAME="${SERVICE_FILENAME:-ssh}"
SERVICE_NAME="${SERVICE_NAME:-ssh}"
SERVICE_TYPE="${SERVICE_TYPE:-_ssh._tcp}"
SERVICE_PORT="${SERVICE_PORT:-22}"

cat <<EOF > /etc/avahi/services/${SERVICE_FILENAME}.service
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<!-- See avahi.service(5) for more information about this configuration file -->

<service-group>

  <name replace-wildcards="${REPLACE_WILDCARDS}">${SERVICE_NAME}</name>

  <service>
    <type>${SERVICE_TYPE}</type>
    <port>${SERVICE_PORT}</port>
  </service>

</service-group>
EOF
exit 0
