# infra-packages/aws/security_groups_unop/variables.tf

# Wrapper-Specific Variables
variable "context_name" {
  description = "The name of the resource or component this SG is for (e.g., 'rds', 'batch')."
  type        = string
}

variable "project_prefix" {
  description = "A prefix for all resources to ensure uniqueness (e.g., 'metaflow-prod')."
  type        = string
}

variable "common_tags" {
  description = "A map of tags to be applied to all security groups created by this module."
  type        = map(string)
  default     = {}
}

# Pass-Through Variables
variable "vpc_id" {
  description = "Required: The ID of the VPC where the security group will be created."
  type        = string
}

variable "additional_tags" {
  description = "Optional: Merged with common_tags to allow resource-specific tagging."
  type        = map(string)
  default     = {}
}

variable "ingress_with_source_security_group_id" {
  description = "The primary mechanism for allowing ingress from other resources (e.g., Batch SG -> RDS SG)."
  type        = list(any)
  default     = []
}

variable "ingress_with_cidr_blocks" {
  description = "Allows ingress from specific network ranges (e.g., a bastion host or corporate VPN)."
  type        = list(any)
  default     = []
}

variable "egress_with_cidr_blocks" {
  description = "Allows egress to the internet ('0.0.0.0/0') or specific VPC endpoints."
  type        = list(any)
  default     = []
}

variable "egress_with_source_security_group_id" {
  description = "Less common, but allows for specific egress paths to other security groups."
  type        = list(any)
  default     = []
}
