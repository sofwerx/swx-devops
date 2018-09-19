#!/bin/bash
seq 0 7 | while read number ; do
  swx dm env swx-u-ub-orange$number
  docker-compose build cassandra
  docker-compose up -d --force-recreate cassandra
done
