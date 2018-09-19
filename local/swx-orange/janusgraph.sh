#!/bin/bash
seq 0 7 | while read number ; do
  swx dm env swx-u-ub-orange$number
  docker-compose build janusgraph
  docker-compose up -d --force-recreate janusgraph
done
