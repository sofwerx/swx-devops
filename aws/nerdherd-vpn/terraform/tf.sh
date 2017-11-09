if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=nerdherd/vpn/terraform.tfstate"
fi
