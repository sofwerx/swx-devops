if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/redrange1/terraform.tfstate"
fi
