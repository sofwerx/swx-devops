#!/bin/bash -xe
docker stack ps galera || docker stack deploy --compose-file galera.yml galera
docker stack ps adminer || docker stack deploy --compose-file adminer.yml adminer
