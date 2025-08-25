# shared-modules/wrapped/vpc_metaflow/variables.tf

variable "name_prefix" {
  description = "A mandatory prefix used for naming all resources created within the module (e.g., metaflow-prod, data-science-dev)."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC. Must be a /16 block (e.g., 10.10.0.0/16) to allow for predictable subnet calculation."
  type        = string
}

variable "availability_zone" {
  description = "The single AWS Availability Zone into which all network resources will be deployed (e.g., us-east-2a)."
  type        = string
  default     = "us-east-2a"
}

variable "tags" {
  description = "A map of AWS tags to apply to all provisioned resources for cost allocation, automation, and identification."
  type        = map(string)
  default     = {}
}

variable "gateway_endpoints" {
  description = "A list of gateway endpoint services to create (e.g., s3, dynamodb)."
  type        = list(string)
  default     = ["s3", "dynamodb"]
}

variable "aws_region" {
  description = "AWS region for VPC endpoint service names."
  type        = string
  default     = "us-east-2"
}
