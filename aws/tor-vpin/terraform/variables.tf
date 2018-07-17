variable Project {
  description = "Project name"
  default = "tor"
}

variable Lifecycle {
  description = "Lifecycle (dev, qa, prod)"
  default = "vpin"
}

variable aws_access_key_id {
  description = "AWS Access Key"
}

variable aws_secret_access_key {
  description = "AWS Secret Key"
}

variable aws_region {
  description = "AWS Region"
  default = "us-east-1"
}

variable vpc_network_cidr {
  description = "CIDR block for VPC"
  default = "10.0.0.0/16"
}

variable vpc_subnet_network_bits {
  description = "Number of bits in addition to vpc_network_cidr used for network part of subnet mask"
  default = 6 
}

variable vpc_subnet_count {
  description = "Number of subnets to create"
  default = 1
}

variable "aws_availability_zones" {
  description = "Comma separated list of availability zones to use by region"
  default = {
    "us-east-1" = "us-east-1a,us-east-1b,us-east-1c",
    "us-west-1" = "us-west-1a,us-west-1b,us-west-1c"
  }
}

# From: http://cloud-images.ubuntu.com/locator/ec2/
# Search for: bionic hvm:ebs-ssd
# As of: 2017-07-17
#
# us-east-1      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-5cc39523 hvm
# us-west-1      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-d7b355b4 hvm
# ap-northeast-1 bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-e875a197 hvm
# sa-east-1      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-ccd48ea0 hvm
# ap-southeast-1 bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-31e7e44d hvm
# ca-central-1   bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-c3e567a7 hvm
# ap-south-1     bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-ee8ea481 hvm
# eu-central-1   bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-3c635cd7 hvm
# eu-west-1      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-d2414e38 hvm
# cn-north-1     bionic 18.04 LTS amd64 hvm:ebs-ssd 20180522 ami-a001dfcd hvm
# cn-northwest-1 bionic 18.04 LTS amd64 hvm:ebs-ssd 20180522 ami-e1bbaf83 hvm
# ap-northeast-2 bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-65d86d0b hvm
# ap-southeast-2 bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-23c51c41 hvm
# us-west-2      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-39c28c41 hvm
# us-east-2      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-67142d02 hvm
# eu-west-2      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-ddb950ba hvm
# ap-northeast-3 bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-3aa8a647 hvm
# eu-west-3      bionic 18.04 LTS amd64 hvm:ebs-ssd 20180617 ami-daf040a7 hvm


variable "ami" {
    description = "These are HVM EBS-SSD instance types. If you change these, make sure it is compatible with your chosen instance type, not all AMIs allow all instance types"
    default = {
        us-east-1-ubuntu-18.04 = "ami-5cc39523"
        us-west-1-ubuntu-18.04 = "ami-d7b355b4"
        ap-northeast-1-ubuntu-18.04 = "ami-e875a197"
        sa-east-1-ubuntu-18.04 = "ami-ccd48ea0"
        ap-southeast-1-ubuntu-18.04 = "ami-31e7e44d"
        ca-central-1-ubuntu-18.04 = "ami-c3e567a7"
        ap-south-1-ubuntu-18.04 = "ami-ee8ea481"
        eu-central-1-ubuntu-18.04 = "ami-3c635cd7"
        eu-west-1-ubuntu-18.04 = "ami-d2414e38"
        cn-north-1-ubuntu-18.04 = "ami-a001dfcd"
        cn-northwest-1-ubuntu-18.04 = "ami-e1bbaf83"
        ap-northeast-2-ubuntu-18.04 = "ami-65d86d0b"
        ap-southeast-2-ubuntu-18.04 = "ami-23c51c41"
        us-west-2-ubuntu-18.04 = "ami-39c28c41"
        us-east-2-ubuntu-18.04 = "ami-67142d02"
        eu-west-2-ubuntu-18.04 = "ami-ddb950ba"
        ap-northeast-3-ubuntu-18.04 = "ami-3aa8a647"
        eu-west-3-ubuntu-18.04 = "ami-daf040a7"
    }
}

variable aws_instance_count {
    description = "The number of instances to create"
    default = "1"
}

variable aws_instance_type {
    description = "AWS instance type to use"
    default = "t2.nano"
}

variable linux_distro_name {
    description = "AWS instance linux distro name to use"
    default = "ubuntu"
}

variable linux_distro_version {
    description = "AWS instance linux distro version to use"
    default = "18.04"
}

variable ssh_key_path {
    description = "Path to ssh private key file"
    default = "../../../secrets/ssh/sofwerx"
}

variable ebs_root_volume_size {
    description = "EBS Root Volume Size"
    default = "20"
}

variable tor_da_count {
    description = "Number of DA nodes"
    default = "1"
}

variable tor_relay_count {
    description = "Number of RELAY nodes"
    default = "1"
}

variable tor_bridge_count {
    description = "Number of BRIDGE nodes"
    default = "1"
}

variable tor_exit_count {
    description = "Number of EXIT nodes"
    default = "1"
}

variable s3_bucket {
    description = "s3 bucket to use for service discovery"
    default = "sofwerx-tor-vpin"
}
