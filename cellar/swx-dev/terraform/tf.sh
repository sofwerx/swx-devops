if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/dev/terraform.tfstate"
fi
