if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/xmpp/terraform.tfstate"
fi
