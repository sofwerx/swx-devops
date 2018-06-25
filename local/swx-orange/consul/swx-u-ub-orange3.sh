#!/bin/bash
swx dm env swx-u-ub-orange3
COMPOSE_FILE=swx-u-ub-orange3.yml
docker-compose up -d consul
