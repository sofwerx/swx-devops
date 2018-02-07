# swx-redteam

This is an AWS IPv6 enabled terraform deployment of geoserver and other tools for the Red Team.

This deployment uses docker-compose to a single docker-engine host.

## environment

Before running `terraform` in the `terraform/` directory, or `docker-compose` in the current directory, please be sure to source the environment:

Example:

    icbmbp:swx-redteam ianblenke$ ../../shell.bash
    [sofwerx::] icbmbp:swx-devops ianblenke$ swx environment switch swx-redteam
    [sofwerx:swx-redteam:] icbmbp:swx-devops ianblenke$

Before using `docker-compose` in the current directory, you will also need to switch to the dm enviroment for `swx-a-swx-redteam0`:

    [sofwerx:swx-redteam:] icbmbp:swx-redteam ianblenke$ swx dm env swx-a-swx-redteam0
    [sofwerx:swx-redteam:swx-a-swx-redteam0] icbmbp:swx-redteam ianblenke$

Note: If you change directory into `aws/swx-redteam`, it should automagically set both of these up for you (thanks to the `.dm` file there).

# terraform

Please read the [terraform/README.md](terraform/README.md)

Please use `swx tf` instead of `terraform`, to ensure the correct environment is sourced.

# docker-compose

Make sure you are in the correct environment and are using the correct dm before proceeding.

# guacamole

Guacamole is deployed as docker containers.

    docker-compose build traefik
    docker-compose up -d traefik
    docker-compose build geoserver
    docker-compose up -d geoserver

This container is set to always restart automatically.

