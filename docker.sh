#!/bin/bash
docker build -t swx-devops .
# This only works if the docker-engine can volume mount this directory as shared
docker run -ti --rm --hostname swx-devops --volume ${PWD}/:/swx swx-devops
