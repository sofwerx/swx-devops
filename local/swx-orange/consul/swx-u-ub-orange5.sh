#!/bin/bash
swx dm env swx-u-ub-orange5
COMPOSE_FILE=swx-u-ub-orange5.yml
docker-compose up -d consul
