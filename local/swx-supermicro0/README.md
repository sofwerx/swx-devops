# swx-supermicro0

This is the dual-12core hyperthreaded 32G supermicro chassis with 4 internal 1.86G drives hardware RAID10 running Ubuntu 18.04

This is wired to a SAS 45 drive JBOD array, with 12 of those drives as a ZFS pool.

## Notes on how this host was added to swx-devops

1. Copied README.md here from another project. Edited it to reflect this new environment.

2. Setup ssh key trust on host for swx-admin user.

3. Setup /etc/sudoers with NOPASSWD: for the %admin group

6. Run docker-machine with the generic driver:

    docker-machine create -d generic --generic-ip-address 172.109.152.116 --generic-ssh-port 60022 --generic-engine-port 60376 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-supermicro0

If that fails, you may safely remove it and try it again:

    docker-machine rm -y swx-u-ub-supermicro0

7. Add that docker-machine host as a dm:

    swx dm import swx-u-ub-supermicro0

8. Create a `.dm` file for the dm host to auto-switch when you cd to the directory:

    echo "swx-u-ub-supermicro0" > .dm

9. Setup environment variables for traefik:

    swx environment create swx-supermicro0
    swx environment set DNS_DOMAIN supermicro0.opswerx.org
    swx environment set SUBDOMAINS '"traefik.supermicro0.opswerx.org"'

10. Setup the dm2environment association between the dm host to the environment it is part of, to allow auto-switching to the environment when you cd to the directory:

    trousseau set dm2environment:swx-u-ub-supermicro0 swx-supermicro0

11. Setup environment variable for `docker-compose` to know which `.yml` file to use for this environment, and the ARCH of this environment:

    swx environment set COMPOSE_FILE swx-supermicro0.yml
    swx environment set ARCH x86_64

12. Add the `.trousseau` file to the git repo and commit and push it as a new change:

    git add ../../.trousseau
    git commit -m 'Updating secrets'
    git push

13. Add CNAME records in Route53 to point `*.supermicro0.devwerx.org` over to public IP
- Clone the `terraform/` directory from another project
- Edit the `Makefile`, `README.md`, and `tf.sh` to reflect this new environment
- Gut the `variables.tf` and `vpc.tf` to reflect only what is required for the AWS Route53 record resources
- Run `./tf.sh` to setup the terraform S3 bucket for this environment
- Run `terraform plan` and make sure only 2 new Route53 resources are being created.
- Run `terraform apply` to make the changes

14. Add traefik service

- Copy the `traefik:` service from another environment's `.yml` file into the `swx-supermicro0.yml` file (it is very generic).
- Add the `docker-traefik` submodule:

    git submodule add https://github.com/sofwerx/docker-traefik.git
    cd docker-traefik
    git remote set-url origin git@github.com:sofwerx/docker-traefik.git
    cd ..

- Deploy traefik with `docker-compose`:

    docker-compose up -d traefik

