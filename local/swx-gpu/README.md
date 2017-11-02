# swx-gpu

This is an IBM ppc64le physical GPU server in our local datacenter.

## environment

Before running `swx dc` in this directory, please be sure to source the dm:

    [sofwerx:swx-gpu:] icbmbp:swx-gpu ianblenke$ swx dm env swx-gpu-0
    [sofwerx:swx-gpu:swx-gpu] icbmbp:swx-gpu ianblenke$

Due to `DOCKER_COMPOSE=swx-gpu.yml` in the swx-gpu environment, the `swx-gpu.yml` here is the `docker-compose.yml` that is used when a `swx dc` or `docker-compose` is run.

This docker-compose will spin up a traefik SSL reverse proxy that will allocate an SSL cert automatically from Let's Encrypt using ACME.

This is configured to run tensorflow using GPU, and the 500ms periodicity for triangulate reflects this.

## NOTE:

Whenever the [softwerx/synthetic-target-area-of-interest](synthetic-target-area-of-interest/) repository is updated, it will re-deploy automagically to this docker-engine.

As such, if you push any merged changes to master there, you do not need to run `swx dc` or `docker-compose` manually in that subdirectory to deploy them.

