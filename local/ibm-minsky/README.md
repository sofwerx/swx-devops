# ibm-minsky

This is an IBM ppc64le physical GPU server in our local datacenter.

## environment

Before running `docker-compose` in this directory, please be sure to source the dm:

    [sofwerx::] icbmbp:ibm-minsky ianblenke$ swx dm env ibm-minsky-0
    [sofwerx:ibm-minsky:ibm-minsky] icbmbp:ibm-minsky ianblenke$

Due to `DOCKER_COMPOSE=ibm-minsky.yml` in the ibm-minsky environment, the `ibm-minsky.yml` here is the `docker-compose.yml` that is used when a `docker-compose` is run.

This docker-compose will spin up a traefik SSL reverse proxy that will allocate an SSL cert automatically from Let's Encrypt using ACME.

This is configured to run tensorflow using GPU, and the 500ms periodicity for triangulate reflects this.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.82 --generic-ssh-port 9022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 9376 --engine-storage-driver overlay2 swx-u-ub-minsky
    swx dm import swx-u-ub-minsky

