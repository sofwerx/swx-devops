# rcloud-dev

This _was_ an AT&T Rcloud evaluation instance deployed to AWS. It is currently no longer deployed.

# Creation

This was built using terraform 0.10.7 - if you use a newer version, please have everyone update at the same time to retain sanity.

Before running `terraform`, you will need to have a `.terraform` directory with the shared tfstate from s3.

Either run:

    make

or run this:

    terraform init --backend-config="key=rcloud/dev/terraform.tfstate"

# Destruction

This environment is currently not running, Ian destroyed it today using:

    docker-machine rm rcloud-dev-0
    trousseau del file:secrets/dm/rcloud-dev-0
    swx tf destroy

