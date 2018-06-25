#!/bin/bash
swx dm env swx-u-ub-orange2
COMPOSE_FILE=swx-u-ub-orange2.yml
docker-compose up -d consul
