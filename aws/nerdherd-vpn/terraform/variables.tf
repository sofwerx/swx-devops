variable Project {
  description = "Project name"
  default = "nerdherd"
}

variable Lifecycle {
  description = "Lifecycle (dev, qa, prod)"
  default = "vpn"
}

variable dns_zone {
  description = "DNS Zone"
  default = "devwerx.org."
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
  default = "10.1.0.0/16"
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
    "us-east-1" = "us-east-1a,us-east-1b,us-east-1c"
  }
}

# From: http://cloud-images.ubuntu.com/locator/ec2/
# Search for: trusty hvm:ebs-ssd
# As of: 2017-10-03
#
# ap-northeast-1    xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-15872773    hvm
# ap-northeast-2    xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-7b1cb915    hvm
# ap-south-1        xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-bc0d40d3    hvm
# ap-southeast-1    xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-67a6e604    hvm
# ap-southeast-2    xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-41c12e23    hvm
# ca-central-1      xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-8a71c9ee    hvm
# eu-central-1      xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-97e953f8    hvm
# eu-west-1         xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-add175d4    hvm
# eu-west-2         xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-ecbea388    hvm
# sa-east-1         xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-466b132a    hvm
# us-east-1         xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-da05a4a0    hvm
# us-east-2         xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-336b4456    hvm
# us-west-1         xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-1c1d217c    hvm
# us-west-2         xenial    16.04 LTS    amd64    hvm:ebs-ssd    20171026.1    ami-0a00ce72    hvm

variable "ami" {
    description = "These are HVM EBS-SSD instance types. If you change these, make sure it is compatible with your chosen instance type, not all AMIs allow all instance types"
    default = {
        ap-northeast-1-ubuntu-16.04 = "ami-15872773"
        ap-northeast-2-ubuntu-16.04 = "ami-7b1cb915"
        ap-south-1-ubuntu-16.04 = "ami-bc0d40d3"
        ap-southeast-1-ubuntu-16.04 = "ami-67a6e604"
        ap-southeast-2-ubuntu-16.04 = "ami-41c12e23"
        ca-central-1-ubuntu-16.04 = "ami-8a71c9ee"
        eu-central-1-ubuntu-16.04 = "ami-97e953f8"
        eu-west-1-ubuntu-16.04 = "ami-add175d4"
        eu-west-2-ubuntu-16.04 = "ami-ecbea388"
        sa-east-1-ubuntu-16.04 = "ami-466b132a"
        us-east-1-ubuntu-16.04 = "ami-da05a4a0"
        us-east-2-ubuntu-16.04 = "ami-336b4456"
        us-west-1-ubuntu-16.04 = "ami-1c1d217c"
        us-west-2-ubuntu-16.04 = "ami-0a00ce72"
    }
}

variable aws_instance_count {
    description = "The number of instances to create"
    default = "1"
}

variable aws_instance_type {
    description = "AWS instance type to use"
    default = "t2.micro"
}

variable linux_distro_name {
    description = "AWS instance linux distro name to use"
    default = "ubuntu"
}

variable linux_distro_version {
    description = "AWS instance linux distro version to use"
    default = "16.04"
}

variable ssh_key_path {
    description = "Path to ssh private key file"
    default = "../../../secrets/ssh/sofwerx"
}

variable ebs_root_volume_size {
    description = "EBS Root Volume Size"
    default = "10"
}

