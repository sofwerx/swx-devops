if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/demobox/terraform.tfstate"
fi
