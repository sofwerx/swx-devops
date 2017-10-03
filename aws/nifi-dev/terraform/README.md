# nifi terraform

Setting up terraform s3 remote:

    terraform remote config \
    --backend=s3 \
    --backend-config="bucket=sofwerx-terraform" \
    --backend-config="key=nifi/dev/terraform.tfstate" \
    --backend-config="region=us-east-1"
