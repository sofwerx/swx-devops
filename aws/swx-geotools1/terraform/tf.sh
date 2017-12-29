if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx-geotools1/vpn/terraform.tfstate"
fi
