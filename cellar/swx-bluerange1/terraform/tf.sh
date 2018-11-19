if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/bluerange1/terraform.tfstate"
fi
