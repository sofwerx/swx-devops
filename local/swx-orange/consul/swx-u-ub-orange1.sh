#!/bin/bash
swx dm env swx-u-ub-orange1
COMPOSE_FILE=swx-u-ub-orange1.yml
docker-compose up -d consul
