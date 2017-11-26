variable "security_group_id" {
  description = "The ID of the Security Group to apply the rules"
}

variable "ingress_rules_security_groups" {
  description = "The security group ID to allow access to/from"
  default     = ""
}

variable "ingress_rules_cidrs" {
  description = "List of CIDR blocks"
  default     = ""
}

variable "ingress_rules_prefix_lists" {
  description = "List of prefix list IDs (for allowing access to VPC endpoints)"
  default     = ""
}

variable "egress_rules_security_groups" {
  description = "The security group ID to allow access to/from"
  default     = ""
}

variable "egress_rules_cidrs" {
  description = "List of CIDR blocks"
  default     = ""
}

variable "egress_rules_prefix_lists" {
  description = "List of prefix list IDs (for allowing access to VPC endpoints)"
  default     = ""
}
