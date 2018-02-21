variable Project {
  description = "Project name"
  default = "swx"
}

variable Lifecycle {
  description = "Lifecycle (dev, qa, prod)"
  default = "range2"
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

