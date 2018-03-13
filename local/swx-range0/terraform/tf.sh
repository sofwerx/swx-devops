if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/range0/terraform.tfstate"
fi
