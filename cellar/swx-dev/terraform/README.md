# swx-dev terraform

This _was_ a development instance deployed to AWS. It is currently no longer deployed.

# Note:

This was built using terraform 0.10.7 - if you use a newer version, please have everyone update at the same time to retain sanity.

Before running `terraform`, you will need to have a `.terraform` directory with the shared tfstate from s3.

Either run:

    make

or run this:

    terraform init --backend-config="key=swx/dev/terraform.tfstate"

