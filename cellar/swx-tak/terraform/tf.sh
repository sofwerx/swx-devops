if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/tak/terraform.tfstate"
fi
