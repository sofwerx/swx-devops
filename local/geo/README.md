# geo

This is a local docker-engine host on a mint PC in the "SWX Data" data science network.

## environment

Before running `docker-compose` in this directory, please be sure to source the dm:

    [sofwerx::] icbmbp:geo ianblenke$ swx dm env geo
    [sofwerx:geo:geo] icbmbp:geo ianblenke$

Due to `DOCKER_COMPOSE=geo.yml` in the swx-gpu environment, the `geo.yml` here is the `docker-compose.yml` that is used when a `docker-compose` is run.

This docker-compose will spin up a traefik SSL reverse proxy that will allocate an SSL cert automatically from Let's Encrypt using ACME.

