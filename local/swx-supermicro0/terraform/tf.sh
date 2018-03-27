if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/supermicro0/terraform.tfstate"
fi
