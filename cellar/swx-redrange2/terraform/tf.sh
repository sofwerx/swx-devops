if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/redrange2/terraform.tfstate"
fi
