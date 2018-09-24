if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=shuttlex/terraform.tfstate"
fi
