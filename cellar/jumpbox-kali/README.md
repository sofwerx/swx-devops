# jumpbox-kali

This is an AWS IPv6 enabled terraform deployment of Kali Linux.

This kali deployment uses docker-compose to a single docker-engine host.

## environment

Before running `terraform` in the `terraform/` directory, or `docker-compose` in the current directory, please be sure to source the environment:

Example:

    icbmbp:jumpbox-kali ianblenke$ ../../shell.bash
    [sofwerx::] icbmbp:swx-devops ianblenke$ swx environment switch jumpbox-kali
    [sofwerx:jumpbox-kali:] icbmbp:swx-devops ianblenke$

Before using `docker-compose` in the current directory, you will also need to switch to the dm enviroment for `swx-a-jumpbox-kali0`:

    [sofwerx:jumpbox-kali:] icbmbp:jumpbox-kali ianblenke$ swx dm env swx-a-jumpbox-kali0
    [sofwerx:jumpbox-kali:swx-a-jumpbox-kali0] icbmbp:jumpbox-kali ianblenke$

Note: If you change directory into `aws/jumpbox-kali`, it should automagically set both of these up for you (thanks to the `.dm` file there).

# terraform

Please read the [terraform/README.md](terraform/README.md)

Please use `swx tf` instead of `terraform`, to ensure the correct environment is sourced.

# docker-compose

Make sure you are in the correct environment and are using the correct dm before proceeding.

This runs the kali convergence script:

    docker-compose build kali &&
    docker-compose stop kali &&
    docker-compose rm -f kali &&
    docker-compose up kali

# guacamole

Guacamole is deployed as docker containers.

    docker-compose build traefik postgres guacamole guacd
    docker-compose up -d traefik postgres
    docker-compose up -d guacd guacamole

`guacd` depends on `traefik` having generated Let's Encrypt ACME certificates and stored before it is started.
`guacamole` depends on `postgres` running before it is started.

These containers are set to always restart automatically.

You may use the https web interface via guacamole to access the kali remote desktop.

