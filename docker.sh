#!/bin/bash -x
docker build -t swx-devops .
# This only works if the docker-engine can volume mount this directory as shared
MY_GROUP="$(id -g -n)"
MY_GID="$(id -g)"
MY_UID="$(id -u)"
docker run -ti --rm --hostname swx-devops --volume "${PWD}/:/swx" --volume "${HOME}/:/root" -e "HOME=/root" -e "LOGNAME=${LOGNAME}" -e "USER=${USER}" -e "UID=${MY_UID}" -e "GROUP=${MY_GROUP}" -e "GID=${MY_GID}" -e "DOCKER_SH=1" swx-devops 
