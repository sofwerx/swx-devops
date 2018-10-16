#!/bin/bash
swx dm env swx-u-ub-shuttlex2
COMPOSE_FILE=swx-u-ub-shuttlex2.yml
docker-compose up -d consul
