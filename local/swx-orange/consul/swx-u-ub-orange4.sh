#!/bin/bash
swx dm env swx-u-ub-orange4
COMPOSE_FILE=swx-u-ub-orange4.yml
docker-compose up -d consul
