if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx-redteam/vpn/terraform.tfstate"
fi
