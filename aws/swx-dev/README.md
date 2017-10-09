# swx-dev

This is an AWS IPv6 enabled terraform deployment of a dokku instance for PaaS deployment.

## environment

Before running `swx tf` in the `terraform/` directory, please be sure to source the environment:

Example:

    icbmbp:swx-dev ianblenke$ ../../shell.bash
    [sofwerx:] icbmbp:swx-dev ianblenke$ swx environment switch swx-dev
    [sofwerx:swx-dev] icbmbp:swx-dev ianblenke$

# terraform

Please read the [terraform/README.md](terraform/README.md)

Please use `swx tf` instead of `terraform`, to ensure the correct environment is sourced.

# dokku

The official [dokku](https://github.com/dokku/dokku) [documentation](http://dokku.viewdocs.io/dokku/deployment/application-deployment/) is the best reference.

# Administration

If you have a user account with `admin` in the name, you can run the `dokku` command remotely via ssh.

If you do not have a user account with `admin` in the name, you will find it easiest to ssh into the instance and `su root` to run the `dokku` command.

## User Management

Following the [official documentation on user management](https://github.com/dokku/dokku/blob/master/docs/deployment/user-management.md), here is how I added myself as root:

    dokku ssh-keys:add ianblenke ~/.ssh/id_rsa-ianblenke.pub

## Adding an Application

Following the [official documentation on application management](https://github.com/dokku/dokku/blob/master/docs/deployment/application-management.md), here is how I added the orient app as root:

    dokku apps:create orient

After doing that on the server, I was able to do this locally:

    git clone https://github.com/ianblenke/orient
    cd orient
    git remote add swx-dev dokku@swx-dev-0.devwerx.org:orient
    git push swx-dev master

Dokku sees the Dockerfile in that project, and uses that to build the docker container.
Dokku also pulls the `EXPOSE 9999` out of the Dockerfile to deduce the port to expose publicly.
