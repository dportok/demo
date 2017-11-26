data "aws_availability_zones" "available" {}

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

variable "region" {
  description = "The region where the environment is being built"
}
