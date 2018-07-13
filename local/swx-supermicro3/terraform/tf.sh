if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/supermicro3/terraform.tfstate"
fi
