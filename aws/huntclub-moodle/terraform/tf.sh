if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=huntclub/moodle/terraform.tfstate"
fi
