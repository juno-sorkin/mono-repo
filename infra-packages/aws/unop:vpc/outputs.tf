# infra-packages/aws/vpc_metaflow/outputs.tf

output "vpc_id" {
  description = "The ID of the created VPC. Used by nearly all other modules."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the VPC. Useful for authoring security group rules in other modules."
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "The ID of the single private subnet. The metaflow-runtime and metaflow-metadata modules will deploy their resources here."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The ID of the single public subnet. Provided for optional resources like a bastion host or public-facing load balancer."
  value       = module.vpc.public_subnets
}

output "default_security_group_id" {
  description = "The ID of the default security group for the VPC."
  value       = module.vpc.default_security_group_id
}

output "vpc_endpoints" {
  description = "A map of gateway endpoints created for the VPC."
  value       = aws_vpc_endpoint.gateway
}
