#!/bin/bash
COMPOSE_FILE=traefik_stack.yml docker-compose build traefik
docker stack rm traefik_stack
docker stack deploy --compose-file=traefik_stack.yml traefik_stack
