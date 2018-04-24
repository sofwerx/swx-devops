# swx-demobox

This is openstf mint box for Cam's demo phones.

## Notes on how this host was added to swx-devops

1. Copied README.md from another project (swx-pandora). Edited it to reflect this new environment.

2. Copy over an existing openstf docker-compose.yml from the mobile environment.

3. Add A records in Route53 to point `*.demobox.opswerx.org` over to the guest router public IP 72.109.143.90
- Copy the `terraform/` directory from another project that has only DNS records
- Edit the `Makefile`, `README.md`, and `tf.sh` to reflect this new environment
- Gut the `variables.tf` and `vpc.tf` to reflect only what is required for the AWS Route53 record resources
- Run `./tf.sh` to setup the terraform S3 bucket for this environment
- Run `terraform plan` and make sure only 2 new Route53 resources are being created.
- Run `terraform apply` to make the changes

4. Setup ssh key trust on host (already existed, repurposed box)

5. Setup /etc/sudoers with NOPASSWD: for the %admin group (already existed, repurposed box)

6. Run docker-machine with the generic driver:

    docker-machine create -d generic --generic-ip-address 192.168.16.41 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --engine-storage-driver overlay2 swx-u-ub-demobox

If that fails, you may safely remove it and try it again:

    docker-machine rm -y swx-u-ub-demobox

7. Add that docker-machine host as a dm:

    swx dm import swx-u-ub-demobox

8. Create a `.dm` file for the dm host to auto-switch when you cd to the directory:

    echo "swx-u-ub-demobox" > .dm

9. Create a new environment for "swx-demobox"

    swx environment create swx-demobox

10. Setup the dm2environment association between the dm host to the environment it is part of, to allow auto-switching to the environment when you cd to the directory:

    trousseau set dm2environment:swx-u-ub-demobox swx-demobox

11. Setup environment variables for traefik:

    swx environment set DNS_DOMAIN demobox.opswerx.org
    swx environment set SUBDOMAINS '"traefik.demobox.opswerx.org"'

12. Setup environment variable for `docker-compose` to know which `.yml` file to use for this environment, and the ARCH of this environment:

    swx environment set COMPOSE_FILE swx-demobox.yml
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

15. Since we copied the swx-demobox.yml file from the mobile/mobile.yml for openstf, we can bring up the other containers as well:

    git submodule add https://github.com/sofwerx/docker-openstf.git
    docker-compose up -d

