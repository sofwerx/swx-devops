if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/bluerange2/terraform.tfstate"
fi
