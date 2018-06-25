#!/bin/bash
swx dm env swx-u-ub-orange6
COMPOSE_FILE=swx-u-ub-orange6.yml
docker-compose up -d consul
