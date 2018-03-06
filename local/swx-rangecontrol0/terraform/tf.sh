if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/rangecontrol0/terraform.tfstate"
fi
