# infra-packages/aws/unop_vpc/variables.tf

variable "name_prefix" {
  description = "Prefix for naming all resources (e.g., platform-prod)."
  type        = string
}

variable "vpc_cidr_block" {
  description = "IPv4 CIDR block for the VPC (e.g., 10.10.0.0/16)."
  type        = string
}

# Must be list?
variable "availability_zones" {
  description = "List of Availability Zones to spread subnets across."
  type        = list(string)
  default     = ["us-east-2a", "us-east-2a"]
}

# Subnet creation controls
variable "create_private_subnets" {
  description = "Whether to create private subnets (recommended)."
  type        = bool
  default     = true
}

variable "create_public_subnets" {
  description = "Whether to create public subnets (for bastion/ingress)."
  type        = bool
  default     = true
}

# Subnet sizing and separation
variable "subnet_newbits" {
  description = "New bits when deriving subnet CIDRs from VPC CIDR (e.g., 8 -> /24 subnets from /16 VPC)."
  type        = number
  default     = 8
}

#TODO: consider abstracting
variable "public_subnet_offset" {
  description = "Index offset applied to public subnet CIDR calculation to avoid overlap with private subnets."
  type        = number
  default     = 64
}

# Internet gateway control (no NAT is created regardless)
variable "enable_internet_gateway" {
  description = "Whether to attach an Internet Gateway (useful if public subnets are created)."
  type        = bool
  default     = true
}

# VPC Endpoints
variable "gateway_endpoints" {
  description = "Gateway endpoint services to create (e.g., s3, dynamodb)."
  type        = list(string)
  default     = ["s3", "dynamodb"]
}

variable "interface_endpoints" {
  description = "Interface endpoint services to create (e.g., ecr.api, ecr.dkr)."
  type        = list(string)
  default     = ["ecr.api", "ecr.dkr"]
}

variable "aws_region" {
  description = "AWS region for VPC endpoint service names."
  type        = string
  default     = "us-east-2"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
