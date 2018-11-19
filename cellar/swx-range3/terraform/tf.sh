if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/range3/terraform.tfstate"
fi
