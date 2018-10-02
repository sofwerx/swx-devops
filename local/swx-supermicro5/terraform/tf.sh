if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/supermicro5/terraform.tfstate"
fi
