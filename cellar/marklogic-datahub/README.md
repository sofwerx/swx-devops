# marklogic-datahub

This is an AWS IPv6 enabled terraform provisioned docker deployment of Nifi + Marklogic 8.

This deployment uses docker-compose to a single docker-engine host.

## environment

Before running `terraform` in the `terraform/` directory, or `docker-compose` in the current directory, please be sure to source the environment:

Example:

    icbmbp:marklogic-datahub ianblenke$ ../../shell.bash
    [sofwerx::] icbmbp:swx-devops ianblenke$ swx environment switch marklogic-datahub
    [sofwerx:marklogic-datahub:] icbmbp:swx-devops ianblenke$

Before using `docker-compose` in the current directory, you will also need to switch to the dm enviroment for `swx-a-marklogic-datahub0`:

    [sofwerx:marklogic-datahub:] icbmbp:marklogic-datahub ianblenke$ swx dm env swx-a-marklogic-datahub0
    [sofwerx:marklogic-datahub:swx-a-marklogic-datahub0] icbmbp:marklogic-datahub ianblenke$

Note: If you change directory into `aws/marklogic-datahub`, it should automagically set both of these up for you (thanks to the `.dm` file there).

# terraform

Please read the [terraform/README.md](terraform/README.md)

Please use `swx tf` instead of `terraform`, to ensure the correct environment is sourced.

# docker-compose

Make sure you are in the correct environment and are using the correct dm before proceeding.

This runs the `converge.sh` convergence script:

    docker-compose build converge &&
    docker-compose stop converge &&
    docker-compose rm -f converge &&
    docker-compose up converge

The `docker-compose.yml` for this project is actually the [marklogic-datahub.yml](./marklogic-datahub.yml) file in this folder.

# traefik

There is a deployed Traefik reverse proxy with Let's Encrypt ACME generated SSL certificates, running in a docker container.

The persistence for the SSL certificates are stored in this docker volume:

    marklogicdatahub_traefik-ssl

# guacamole

Guacamole is deployed as docker containers as well.

    docker-compose build traefik postgres guacamole guacd
    docker-compose up -d traefik postgres
    docker-compose up -d guacd guacamole

`guacd` depends on `traefik` having generated Let's Encrypt ACME certificates and stored before it is started.
`guacamole` depends on `postgres` running before it is started.

These containers are set to always restart automatically.

The persistant docker volumes for guacamole are the following:

    marklogicdatahub_guacamole-data
    marklogicdatahub_postgres-data

You may use the https web interface via guacamole to access the remote desktop.

# RDP

This server is running Xrdp for remote desktops.

Guacamole is just a web interface to an RDP session into this server.

You may also use "Microsoft Remote Desktop" or any other RDP capable thin-client to access this server directly as `datahub.devwerx.org` on the standard port 3389.

Filesharing is supported.

# NIFI

Nifi is deployed in a docker container, and uses the following docker volumes for persistence:

    marklogicdatahub_content_repository
    marklogicdatahub_database_repository
    marklogicdatahub_flowfile_repository
    marklogicdatahub_provenance_repository

While inside a Guacamole/RDP session, you can browse to the NIFI web interface on localhost:

    http://localhost:8080

This is also exposed via traefik to the outside world.

# Marklogic 8

Marklogic 8 is deployed in a docker container using only one volume for persistence:

    marklogicdatahub_datahub-data

While inside a Guacamole/RDP session, you can browse to the marklogic web interface on localhost:

    http://localhost:8001

This is not exposed via traefik to the outside world. Instead, the marklogic application port is exposed.

