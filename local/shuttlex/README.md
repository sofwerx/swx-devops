# swx-shuttlex

These are 8G shuttle PCs with nVidia GTX-1050s running Pop-OS in a docker swarm cluster.

The OSes arel on the 256G NVMe drives, and docker store is on the 1G internal drives.

## Notes on how this host was added to swx-devops

1. Copied README.md here from another project. Edited it to reflect this new environment.

2. Setup ssh key trust on host for swx-admin user.

3. Setup /etc/sudoers with NOPASSWD: for the %admin group

5. Make sure the firewall has ports forwarded to the machines.

- https://192.168.1.1:65443/

    40022 192.168.1.71 22
    40443 192.168.1.71 443
    40376 192.168.1.71 2376
    41022 192.168.1.72 22
    41443 192.168.1.72 443
    41376 192.168.1.72 2376
    42022 192.168.1.73 22
    42443 192.168.1.73 443
    42376 192.168.1.73 2376
    43022 192.168.1.74 22
    43443 192.168.1.74 443
    43376 192.168.1.74 2376

6. Run docker-machine with the generic driver:

    docker-machine create -d generic --generic-ip-address 172.109.143.82 --generic-ssh-port 40022 --generic-engine-port 40376 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-shuttlex0
    docker-machine create -d generic --generic-ip-address 172.109.143.82 --generic-ssh-port 41022 --generic-engine-port 41376 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-shuttlex1
    docker-machine create -d generic --generic-ip-address 172.109.143.82 --generic-ssh-port 42022 --generic-engine-port 42376 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-shuttlex2
    docker-machine create -d generic --generic-ip-address 172.109.143.82 --generic-ssh-port 43022 --generic-engine-port 43376 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-shuttlex3

If that fails, you may safely remove it and try it again:

    docker-machine rm -y swx-u-ub-shuttlex0

7. Add that docker-machine host as a dm:

    swx dm import swx-u-ub-shuttlex0

8. Create a `.dm` file for the dm host to auto-switch when you cd to the directory:

    echo "swx-u-ub-shuttlex0" > .dm

9. Setup environment variables for traefik:

    swx environment create shuttlex
    swx environment set DNS_DOMAIN shuttlex.opswerx.org

10. Setup the dm2environment association between the dm host to the environment it is part of, to allow auto-switching to the environment when you cd to the directory:

    trousseau set dm2environment:swx-u-ub-shuttlex0 shuttlex

11. Setup environment variable for `docker-compose` to know which `.yml` file to use for this environment, and the ARCH of this environment:

    swx environment set COMPOSE_FILE shuttlex.yml
    swx environment set ARCH x86_64

12. Add the `.trousseau` file to the git repo and commit and push it as a new change:

    git add ../../.trousseau
    git commit -m 'Updating secrets'
    git push

13. Add CNAME records in Route53 to point `*.shuttlex.devwerx.org` over to public IP
- Clone the `terraform/` directory from another project
- Edit the `Makefile`, `README.md`, and `tf.sh` to reflect this new environment
- Gut the `variables.tf` and `vpc.tf` to reflect only what is required for the AWS Route53 record resources
- Run `./tf.sh` to setup the terraform S3 bucket for this environment
- Run `terraform plan` and make sure only 2 new Route53 resources are being created.
- Run `terraform apply` to make the changes

14. Add traefik service

- Copy the `traefik:` service from another environment's `.yml` file into the `shuttle.yml` file (it is very generic).
- Add the `docker-traefik` submodule:

    git submodule add https://github.com/sofwerx/docker-traefik.git
    cd docker-traefik
    git remote set-url origin git@github.com:sofwerx/docker-traefik.git
    cd ..

- Deploy traefik with `docker-compose`:

    docker-compose up -d traefik

