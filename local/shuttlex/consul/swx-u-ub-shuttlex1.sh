#!/bin/bash
swx dm env swx-u-ub-shuttlex1
COMPOSE_FILE=swx-u-ub-shuttlex1.yml
docker-compose up -d consul
