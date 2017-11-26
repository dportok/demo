variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
}

variable "enable_dns_support" {
  description = "Should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "name" {
  description = "The name of the VPC"
  default     = "Webserver"
}

variable "environment" {
  description = "The environment: Support, Modelling or Scoring"
  default     = "Demonstration"
}

variable "managed" {
  description = "Managed by Terraform"
  default     = "Managed by Terraform"
}

variable "azones" {
  description = "The availability zone where the VPC will be created"
}

variable "public_cidr_block" {
  description = "The CIDR of the public subnet"
}

variable "private_cidr_block" {
  description = "The CIDR of the private subnet"
}
