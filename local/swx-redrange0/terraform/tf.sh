if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/redrange0/terraform.tfstate"
fi
