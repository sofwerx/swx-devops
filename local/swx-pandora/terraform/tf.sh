if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/pandora/terraform.tfstate"
fi
