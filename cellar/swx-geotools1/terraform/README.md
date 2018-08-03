# swx-geotools1 terraform

This is a VPN cloud anchor instance in AWS.

# Note:

This was built using terraform 0.11.5 - if you use a newer version, please have everyone update at the same time to retain sanity.

Before running `terraform`, you will need to have a `.terraform` directory with the shared tfstate from s3.

Either run:

    make

or run this:

    terraform init --backend-config="key=swx-geotools1/terraform.tfstate"

