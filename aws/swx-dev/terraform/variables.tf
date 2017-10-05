variable Project {
  description = "Project name"
  default = "swx"
}

variable Environment {
  description = "Lifecycle (dev, qa, prod)"
  default = "dev"
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
# ap-northeast-1    trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-645c9302    hvm
# ap-southeast-1    trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-fb94e398    hvm
# eu-central-1      trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-04388e6b    hvm
# eu-west-1         trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-e872bf91    hvm
# sa-east-1         trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-b4b2cfd8    hvm
# us-east-1         trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-44e10d3e    hvm
# us-west-1         trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-66a29406    hvm
# ap-southeast-2    trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-14e20476    hvm
# us-west-2         trusty    14.04 LTS    amd64    hvm:ebs-ssd    20170918    ami-e7fe039f    hvm

variable "ami" {
    description = "These are HVM EBS-SSD instance types. If you change these, make sure it is compatible with your chosen instance type, not all AMIs allow all instance types"
    default = {
        ap-northeast-1-ubuntu-16.04 = "ami-645c9302"
        ap-southeast-1-ubuntu-16.04 = "ami-fb94e398"
        eu-central-1-ubuntu-16.04 = "ami-04388e6b"
        eu-west-1-ubuntu-16.04 = "ami-e872bf91"
        sa-east-1-ubuntu-16.04 = "ami-b4b2cfd8"
        us-east-1-ubuntu-16.04 = "ami-44e10d3e"
        us-west-1-ubuntu-16.04 = "ami-66a29406"
        ap-southeast-2-ubuntu-16.04 = "ami-14e20476"
        us-west-2-ubuntu-16.04 = "ami-e7fe039f"
    }
}

variable aws_instance_count {
    description = "The number of instances to create"
    default = "1"
}

variable aws_instance_type {
    description = "AWS instance type to use"
    default = "m4.large"
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
    default = "~/.ssh/id_rsa.sofwerx"
}

variable ebs_root_volume_size {
    description = "EBS Root Volume Size"
    default = "20"
}

variable ebs_home_volume_size {
    description = "EBS Home Volume Size"
    default = "50"
}

variable ebs_docker_volume_size {
    description = "EBS Docker Volume Size"
    default = "100"
}

