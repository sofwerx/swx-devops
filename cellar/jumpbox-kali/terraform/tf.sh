if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=jumpbox/kali/terraform.tfstate"
fi
