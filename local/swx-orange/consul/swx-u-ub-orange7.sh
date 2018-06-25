#!/bin/bash
swx dm env swx-u-ub-orange7
COMPOSE_FILE=swx-u-ub-orange7.yml
docker-compose up -d consul
