# rcloud-dev

This is an AWS IPv6 enabled terraform deployment of rcloud.

This rcloud deployment uses docker-compose to a single docker-engine host.

## environment

Before running `terraform apply` in the `terraform/` directory, or `docker-compose up` in the current directory, please be sure to source the environment:

Example:

    icbmbp:rcloud-dev ianblenke$ ../../shell.bash
    [sofwerx:] icbmbp:rcloud-dev ianblenke$ switch_environment rcloud-dev
    [sofwerx:rcloud-dev] icbmbp:rcloud-dev ianblenke$

# terraform

Please read the [terraform/README.md](terraform/README.md)

# docker-compose

Before using docker-compose, you will also need to switch to the dm enviroment for `rcloud-dev-0`:

    [sofwerx:rcloud-dev] icbmbp:rcloud-dev ianblenke$ dm_env rcloud-dev-0

Now you can look at the running containers using the `docker` or `docker-compose` commands:

    docker ps -a
    docker-compose ps -a

This does a full rebuild of the rcloud container:

    docker-compose build rcloud &&
    docker-compose stop rcloud &&
    docker-compose rm -f rcloud &&
    docker-compose up -d

The rcloud data is persistently stored in docker volumes, as defined at the top of the `docker-compose.yml`:

    docker volume ls

This means that you can safely destroy and recreate the containers, they will pick back up from where they left off.

