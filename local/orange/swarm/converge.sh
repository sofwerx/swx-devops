#!/bin/bash -xe
docker stack ps galera || docker stack deploy --compose-file galera.yml galera
