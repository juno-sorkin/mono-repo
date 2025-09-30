# infra-packages/aws/unop_vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "IDs of created private subnets."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "IDs of created public subnets."
  value       = module.vpc.public_subnets
}

output "private_route_table_ids" {
  description = "Route table IDs associated with private subnets."
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "Route table IDs associated with public subnets."
  value       = module.vpc.public_route_table_ids
}

output "default_security_group_id" {
  description = "The ID of the default security group for the VPC."
  value       = module.vpc.default_security_group_id
}

output "gateway_vpc_endpoints" {
  description = "Gateway VPC endpoints created (by service)."
  value       = aws_vpc_endpoint.gateway
}

output "interface_vpc_endpoints" {
  description = "Interface VPC endpoints created (by service)."
  value       = aws_vpc_endpoint.interface
}

output "interface_endpoints_security_group_id" {
  description = "Security group ID used for interface endpoints."
  value       = try(aws_security_group.interface_endpoints[0].id, null)
}
