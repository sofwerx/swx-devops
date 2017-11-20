# rcloud-dev

This _was_ an AWS IPv6 enabled terraform deployment of AT&T's Rcloud. It is no longer deployed.

This rcloud deployment uses docker-compose to a single docker-engine host.

## environment

Before running `terraform` in the `terraform/` directory, or `docker-compose` in the current directory, please be sure to source the environment:

Example:

    icbmbp:rcloud-dev ianblenke$ ../../shell.bash
    [sofwerx::] icbmbp:rcloud-dev ianblenke$ swx environment switch rcloud-dev
    [sofwerx:rcloud-dev:] icbmbp:rcloud-dev ianblenke$

Before using `docker-compose` in the current directory, you will also need to switch to the dm enviroment for `rcloud-dev-0`:

    [sofwerx:rcloud-dev:] icbmbp:rcloud-dev ianblenke$ swx dm env rcloud-dev-0
    [sofwerx:rcloud-dev:rcloud-dev-0] icbmbp:rcloud-dev ianblenke$

# terraform

Please read the [terraform/README.md](terraform/README.md)

Please use `swx tf` instead of `terraform`, to ensure the correct environment is sourced.

# docker-compose

Make sure you are in the correct environment and are using the correct dm before proceeding.

This does a full rebuild of the rcloud container:

    docker-compose build rcloud &&
    docker-compose stop rcloud &&
    docker-compose rm -f rcloud &&
    docker-compose up -d

The rcloud data is persistently stored in docker volumes, as defined at the top of the `docker-compose.yml`:

    docker volume ls

This means that you can safely destroy and recreate the containers, they will pick back up from where they left off.

