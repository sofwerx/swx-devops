# swx-pandora

This is multi-ethernet embedded celeron server running pandora-fms in our underground location

## environment

Before running `docker-compose` in this directory, please be sure to source the dm:

    [sofwerx::] icbmbp:swx-pandora ianblenke$ swx dm env swx-u-ub-pandora
    [sofwerx:swx-pandora:swx-pandora] icbmbp:swx-pandora ianblenke$

Due to `DOCKER_COMPOSE=swx-pandora.yml` in the swx-pandora environment, the `swx-pandora.yml` here is the `docker-compose.yml` that is used when a `docker-compose` is run.

This docker-compose will spin up a traefik SSL reverse proxy that will allocate an SSL cert automatically from Let's Encrypt using ACME.

## Notes on how this host was added to swx-devops

1. Copied README.md from another project. Edited it to reflect this new environment.

2. Setup submodule for docker-pandorafms from https URL, and setup ssh 

    git submodule add https://github.com/sofwerx/docker-pandorafms.git
    git commit -m 'Adding docker-pandorafms submodule to swx-pandorafms environment'
    cd docker-pandorafms
    git remote set-url origin git@github.com:sofwerx/docker-pandorafms.git
    cd ..

3. Add CNAME records in Route53 to point `*.pandora.devwerx.org` over to `sofwerxbrange.araknisdns.com`
- Clone the `terraform/` directory from another project
- Edit the `Makefile`, `README.md`, and `tf.sh` to reflect this new environment
- Gut the `variables.tf` and `vpc.tf` to reflect only what is required for the AWS Route53 record resources
- Run `./tf.sh` to setup the terraform S3 bucket for this environment
- Run `terraform plan` and make sure only 2 new Route53 resources are being created.
- Run `terraform apply` to make the changes

4. Setup ssh key trust on host:

5. Setup /etc/sudoers with NOPASSWD: for the %admin group

6. Run docker-machine with the generic driver:

    docker-machine create -d generic --generic-ip-address 192.168.1.100 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-pandora

If that fails, you may safely remove it and try it again:

    docker-machine rm -y swx-u-ub-pandora

7. Add that docker-machine host as a dm:

    swx dm import swx-u-ub-pandora

8. Create a `.dm` file for the dm host to auto-switch when you cd to the directory:

    `echo "swx-u-ub-pandora" > .dm

9. Setup the dm2environment association between the dm host to the environment it is part of, to allow auto-switching to the environment when you cd to the directory:

    trousseau set dm2environment:swx-u-ub-pandora swx-pandora

10. Setup environment variables for traefik:

    swx environment set DNS_DOMAIN pandora.devwerx.org
    swx environment set SUBDOMAINS '"traefik.pandora.devwerx.org"'

11. Setup environment variable for `docker-compose` to know which `.yml` file to use for this environment, and the ARCH of this environment:

    swx environment set COMPOSE_FILE swx-pandora.yml
    swx environment set ARCH x86_64

12. Add the `.trousseau` file to the git repo and commit and push it as a new change:

    git add .trousseau
    git commit -m 'Updating secrets'
    git push

13. Add traefik service

- Copy the `traefik:` service from another environment's `.yml` file into the `swx-pandora.yml` file (it is very generic).
- Add the `docker-traefik` submodule:

    git submodule add https://github.com/sofwerx/docker-traefik.git
    cd docker-traefik
    git remote set-url origin git@github.com:sofwerx/docker-traefik.git
    cd ..

- Deploy traefik with `docker-compose`:

    docker-compose up -d traefik

