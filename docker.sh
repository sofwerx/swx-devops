#!/bin/bash -v
docker build -t swx-devops .
# This only works if the docker-engine can volume mount this directory as shared

docker run -ti --rm --hostname swx-devops --volume "${PWD}/:/swx" --volume "${HOME}/:/root" --user "`id -u ${LOGNAME}`" -e "HOME=/root" -e "LOGNAME=${LOGNAME}" -e "USER=${USER}" swx-devops 
