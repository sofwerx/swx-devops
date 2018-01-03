variable Project {
  description = "Project name"
  default = "jumpbox"
}

variable Lifecycle {
  description = "Lifecycle (dev, qa, prod)"
  default = "kali"
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

variable "ami" {
    description = "These are HVM EBS-SSD instance types. If you change these, make sure it is compatible with your chosen instance type, not all AMIs allow all instance types"
    default = {
        ap-northeast-1-debian-stretch = "ami-f0188d96"
        ap-northeast-2-debian-stretch = "ami-6a9d3c04"
        ap-south-1-debian-stretch = "ami-8892d8e7"
        ap-southeast-1-debian-stretch = "ami-c09af3bc"
        ap-southeast-2-debian-stretch = "ami-b6d525d4"
        ca-central-1-debian-stretch = "ami-1545ff71"
        eu-central-1-debian-stretch = "ami-e49e098b"
        eu-west-1-debian-stretch = "ami-d133bfa8"
        eu-west-2-debian-stretch = "ami-babea7de"
        eu-west-3-debian-stretch = "ami-d0398ead"
        sa-east-1-debian-stretch = "ami-7027671c"
        us-east-1-debian-stretch = "ami-7c6b2d06"
        us-east-2-debian-stretch = "ami-95b79ff0"
        us-west-1-debian-stretch = "ami-aa1610ca"
        us-west-2-debian-stretch = "ami-f1e74889"
    }
}

variable aws_instance_count {
    description = "The number of instances to create"
    default = "1"
}

variable aws_instance_type {
    description = "AWS instance type to use"
    default = "t2.small"
}

variable linux_distro_name {
    description = "AWS instance linux distro name to use"
    default = "debian"
}

variable linux_distro_version {
    description = "AWS instance linux distro version to use"
    default = "stretch"
}

variable ssh_key_path {
    description = "Path to ssh private key file"
    default = "../../../secrets/ssh/sofwerx"
}

variable ebs_root_volume_size {
    description = "EBS Root Volume Size"
    default = "20"
}

