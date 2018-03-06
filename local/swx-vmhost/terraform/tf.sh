if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/vmhost/terraform.tfstate"
fi
