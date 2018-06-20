if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/datascience/terraform.tfstate"
fi
