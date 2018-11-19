if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/range1/terraform.tfstate"
fi
