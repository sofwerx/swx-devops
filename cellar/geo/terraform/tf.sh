if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/geo/terraform.tfstate"
fi
