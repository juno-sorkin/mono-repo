# shared-modules/wrapped/vpc_metaflow/main.tf

locals {
  public_subnet_cidr  = cidrsubnet(var.vpc_cidr_block, 4, 0) # /20
  private_subnet_cidr = cidrsubnet(var.vpc_cidr_block, 4, 1) # /20
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr_block
  azs  = [var.availability_zone]

  public_subnets  = [local.public_subnet_cidr]
  private_subnets = [local.private_subnet_cidr]

  # Assign public IPs to instances in public subnets
  map_public_ip_on_launch = true

  # --- Opinionated Configuration for Metaflow ---

  # Disable NAT Gateway for cost-effectiveness
  enable_nat_gateway = false
  single_nat_gateway = false

  tags = var.tags
}

# VPC Endpoints for S3 and DynamoDB (direct resource creation)
resource "aws_vpc_endpoint" "gateway" {
  for_each = toset(var.gateway_endpoints)

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids = flatten([
    module.vpc.public_route_table_ids,
    module.vpc.private_route_table_ids
  ])

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-${each.key}-vpc-endpoint"
    Terraform = "true"
    Module    = "vpc_metaflow"
  })
}
