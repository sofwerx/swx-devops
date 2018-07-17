if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=tor/vpin/terraform.tfstate"
fi
