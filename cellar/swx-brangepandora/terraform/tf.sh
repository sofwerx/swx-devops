if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/brangepandora/terraform.tfstate"
fi
