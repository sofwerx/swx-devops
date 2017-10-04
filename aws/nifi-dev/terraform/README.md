# nifi terraform

Before running `terraform`, you will need to initialize our s3 remote for the shared tfstate file.

Either run `make`, or run this:

    terraform init --backend-config="key=nifi/dev/terraform.tfstate" \
                   --backend-config="region=us-east-1"

