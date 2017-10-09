if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=rcloud/dev/terraform.tfstate"
fi
