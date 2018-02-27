if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/orange/terraform.tfstate"
fi
