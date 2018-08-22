if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/supermicro2/terraform.tfstate"
fi
