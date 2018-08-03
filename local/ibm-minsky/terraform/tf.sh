if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=ibm/minsky/terraform.tfstate"
fi
