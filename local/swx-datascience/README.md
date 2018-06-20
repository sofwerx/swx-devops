# swx-datascience

This is the Sofwerx Underground hosted datascience kubernetes cluster.

This consists of:

6 x dual-12core hyperthreaded 32G supermicro chassis with 4 internal 1.86G drives hardware RAID10 running Ubuntu 18.04
  4 of these are wired to a SAS 45 drive JBOD array, each with a ZFS pool carved out of those drives.

8 x single-8core hyperthreaded Xeon 64G tranquilpc single blade chassis each with 1x120G and 1x1TB drives running Ubuntu 18.04

## Notes on how this host was added to swx-devops

1. Copied README.md here from another project. Edited it to reflect this new environment.

2. Setup ssh key trust on host for swxadmin user.

3. Setup /etc/sudoers with NOPASSWD: for the %admin group

6. Run docker-machine with the generic driver:

For the supermicro servers, with the ZFS volume driver:

    docker-machine create -d generic --generic-ip-address 192.168.1.60 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver zfs swx-u-ub-supermicro0
    docker-machine create -d generic --generic-ip-address 192.168.1.62 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver zfs swx-u-ub-supermicro2
    docker-machine create -d generic --generic-ip-address 192.168.1.64 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver zfs swx-u-ub-supermicro4

For the tranquilpc "orange box" with the overlay2 volume driver:

    docker-machine create -d generic --generic-ip-address 192.168.1.120 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange0
    docker-machine create -d generic --generic-ip-address 192.168.1.121 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange1
    docker-machine create -d generic --generic-ip-address 192.168.1.122 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange2
    docker-machine create -d generic --generic-ip-address 192.168.1.123 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange3
    docker-machine create -d generic --generic-ip-address 192.168.1.124 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange4
    docker-machine create -d generic --generic-ip-address 192.168.1.125 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange5
    docker-machine create -d generic --generic-ip-address 192.168.1.126 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange6
    docker-machine create -d generic --generic-ip-address 192.168.1.127 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-orange7

If you run into any problems doing this, you may safely remove them and try again:

    docker-machine rm -y swx-u-ub-supermicro0

You may find that docker-machine can't find dockerd, and that's likely because docker-machine is not setting the storage driver correctly in the systemd service (overlay2 instead of zfs), which can be worked around by sshing into the host and running:

    sed -i -e s/overlay2/zfs/ /etc/systemd/system/docker.service.d/10-machine.conf
    systemctl daemon-reload
    systemctl start docker

7. Add each docker-machine host as a dm:

    swx dm import swx-u-ub-supermicro0
    swx dm import swx-u-ub-supermicro1
    swx dm import swx-u-ub-supermicro2
    swx dm import swx-u-ub-supermicro3
    swx dm import swx-u-ub-supermicro4
    swx dm import swx-u-ub-supermicro5
    swx dm import swx-u-ub-orange0
    swx dm import swx-u-ub-orange1
    swx dm import swx-u-ub-orange2
    swx dm import swx-u-ub-orange3
    swx dm import swx-u-ub-orange4
    swx dm import swx-u-ub-orange5
    swx dm import swx-u-ub-orange6
    swx dm import swx-u-ub-orange7

8. Create a `.dm` file for the default dm host to auto-switch when you cd to the directory:

    echo "swx-u-ub-supermicro0" > .dm

9. Setup environment variables for traefik:

    swx environment create swx-supermicro0
    swx environment set DNS_DOMAIN datascience.opswerx.org

10. Setup the dm2environment association between the dm host to the environment it is part of, to allow auto-switching to the environment when you cd to the directory:

    trousseau set dm2environment:swx-u-ub-supermicro0 swx-datascience
    trousseau set dm2environment:swx-u-ub-supermicro1 swx-datascience
    trousseau set dm2environment:swx-u-ub-supermicro2 swx-datascience
    trousseau set dm2environment:swx-u-ub-supermicro3 swx-datascience
    trousseau set dm2environment:swx-u-ub-supermicro4 swx-datascience
    trousseau set dm2environment:swx-u-ub-supermicro5 swx-datascience
    trousseau set dm2environment:swx-u-ub-orange0 swx-datascience
    trousseau set dm2environment:swx-u-ub-orange1 swx-datascience
    trousseau set dm2environment:swx-u-ub-orange2 swx-datascience
    trousseau set dm2environment:swx-u-ub-orange3 swx-datascience
    trousseau set dm2environment:swx-u-ub-orange4 swx-datascience
    trousseau set dm2environment:swx-u-ub-orange5 swx-datascience
    trousseau set dm2environment:swx-u-ub-orange6 swx-datascience

11. Setup environment variable for `docker-compose` to know which `.yml` file to use for this environment, and the ARCH of this environment:

    swx environment set COMPOSE_FILE swx-supermicro0.yml
    swx environment set ARCH x86_64

12. Add the `.trousseau` file to the git repo and commit and push it as a new change:

    git add ../../.trousseau
    git commit -m 'Updating secrets'
    git push

13. Add DNS records in Route53 to point `*.datascience.devwerx.org` to the cluster public IP
- Clone the `terraform/` directory from another project
- Edit the `Makefile`, `README.md`, and `tf.sh` to reflect this new environment
- Gut the `variables.tf` and `vpc.tf` to reflect only what is required for the AWS Route53 record resources
- Run `./tf.sh` to setup the terraform S3 bucket for this environment
- Run `terraform plan` and make sure only 2 new Route53 resources are being created.
- Run `terraform apply` to make the changes

14. Add traefik service

- Copy the `traefik:` service from another environment's `.yml` file into the `swx-pandora.yml` file (it is very generic).
- Add the `docker-traefik` submodule:

    git submodule add https://github.com/sofwerx/docker-traefik.git
    cd docker-traefik
    git remote set-url origin git@github.com:sofwerx/docker-traefik.git
    cd ..

- Deploy traefik with `docker-compose`:

    docker-compose up -d traefik

