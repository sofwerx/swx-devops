if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/blueteam/terraform.tfstate"
fi
