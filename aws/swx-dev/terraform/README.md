# swx-dev terraform

Before running `terraform`, you will need to initialize our s3 remote for the shared tfstate file.

Either run `make`, or run this:

    terraform init --backend-config="key=swx/dev/terraform.tfstate"

