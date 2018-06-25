#!/bin/bash
swx dm env swx-u-ub-orange0
COMPOSE_FILE=swx-u-ub-orange0.yml
docker-compose up -d consul
