all: .terraform plan

plan:
	terraform plan

apply:
	terraform apply

.terraform:
	terraform init --backend-config="key=nifi/dev/terraform.tfstate"
