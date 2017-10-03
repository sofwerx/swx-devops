provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
}

terraform {
  backend "s3" {
    bucket = "sofwerx-terraform"
    key    = "${var.Project}/${var.Environment}"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "sofwerx-terraform"
    key    = "${var.Project}/${var.Environment}/terraform.tfstate"
    region = "us-east-1"
  }
}
