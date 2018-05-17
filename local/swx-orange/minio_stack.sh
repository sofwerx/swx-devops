#!/bin/bash
docker stack rm minio_stack
docker stack deploy --compose-file=minio_stack.yml minio_stack
