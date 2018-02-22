if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=swx/bluerange0/terraform.tfstate"
fi
