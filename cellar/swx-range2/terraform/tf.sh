if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/range2/terraform.tfstate"
fi
