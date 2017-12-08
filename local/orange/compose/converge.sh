#!/bin/bash -xe
for number in $(seq 0 7) ; do swx dm env swx-u-r-node$number ; COMPOSE_FILE=swx-u-r-node${number}.yml docker-compose up -d ; done
