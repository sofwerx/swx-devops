#!/bin/bash
swx dm env swx-u-ub-shuttlex0
COMPOSE_FILE=swx-u-ub-shuttlex0.yml
docker-compose up -d consul
