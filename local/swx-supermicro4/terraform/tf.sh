if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/supermicro4/terraform.tfstate"
fi
