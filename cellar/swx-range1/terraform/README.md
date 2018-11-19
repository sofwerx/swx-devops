# swx-range1 terraform

This is for AWS Route53 DNS resources for swx-u-ub-range1

# Note:

This was built using terraform 0.11.3 - if you use a newer version, please have everyone update at the same time to retain sanity.

Before running `terraform`, you will need to have a `.terraform` directory with the shared tfstate from s3.

Either run:

    make

or the `tf.sh` script:

    ./tf.sh

or run this:

    terraform init --backend-config="key=swx/range1/terraform.tfstate"

