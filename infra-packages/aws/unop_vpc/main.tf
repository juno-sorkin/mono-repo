# infra-packages/aws/unop_vpc/main.tf

locals {
  # Resolve AZs: prefer explicit list, else single AZ for backward compatibility
  azs = length(var.availability_zones) > 0 ? var.availability_zones : [var.availability_zone]

  # Subnet sizing and spacing between subnet tiers (private/public)
  subnet_newbits       = var.subnet_newbits
  public_subnet_offset = var.public_subnet_offset

  # Compute CIDRs per AZ for each subnet tier
  private_subnet_cidrs = var.create_private_subnets ? [
    for index, _ in local.azs : cidrsubnet(var.vpc_cidr_block, local.subnet_newbits, index)
  ] : []

  public_subnet_cidrs = var.create_public_subnets ? [
    for index, _ in local.azs : cidrsubnet(var.vpc_cidr_block, local.subnet_newbits, index + local.public_subnet_offset)
  ] : []

  # Whether we will create any interface endpoints
  create_interface_endpoints = length(var.interface_endpoints) > 0
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr_block
  azs  = local.azs

  private_subnets = local.private_subnet_cidrs
  public_subnets  = local.public_subnet_cidrs

  map_public_ip_on_launch = var.create_public_subnets

  # Best practices for PrivateLink-only egress
  enable_nat_gateway = false
  single_nat_gateway = false
  create_igw         = var.enable_internet_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

## Gateway VPC Endpoints (e.g., S3, DynamoDB)
resource "aws_vpc_endpoint" "gateway" {
  for_each = toset(var.gateway_endpoints)

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids = flatten([
    module.vpc.public_route_table_ids,
    module.vpc.private_route_table_ids
  ])

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-${each.value}-gateway-endpoint"
    Terraform = "true"
    Module    = "unop_vpc"
  })
}

## Security group for Interface Endpoints, only when needed
resource "aws_security_group" "interface_endpoints" {
  count       = local.create_interface_endpoints ? 1 : 0
  name_prefix = "${var.name_prefix}-vpce-"
  description = "Security group for Interface VPC Endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-vpce-sg"
    Terraform = "true"
    Module    = "unop_vpc"
  })
}

## Interface VPC Endpoints (e.g., ecr.api, ecr.dkr, logs)
resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_endpoints)

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = length(module.vpc.private_subnets) > 0 ? module.vpc.private_subnets : module.vpc.public_subnets
  security_group_ids = [aws_security_group.interface_endpoints[0].id]

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-${each.value}-interface-endpoint"
    Terraform = "true"
    Module    = "unop_vpc"
  })
}
