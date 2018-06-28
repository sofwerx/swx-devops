#!/bin/bash
#elasticsearch kibana logstash auditbeat filebeat heartbeat metricbeat packetbeat apm_server elasticsearch-hq cerebro
seq 0 7 | while read number ; do
  swx dm env swx-u-ub-orange$number
  docker-compose build setup_kibana
  docker-compose up -d elasticsearch kibana
  docker-compose up -d --force-recreate setup_kibana
  docker-compose build metricbeat setup_metricbeat logstash setup_logstash
  docker-compose up -d --force-recreate setup_metricbeat metricbeat logstash setup_logstash
done
