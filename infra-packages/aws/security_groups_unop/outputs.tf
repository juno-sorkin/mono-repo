# shared-modules/wrapped/security_groups_unop/outputs.tf

output "id" {
  description = "The ID of the security group, used for rule definitions."
  value       = module.security-group.security_group_id
}

output "arn" {
  description = "The ARN of the security group."
  value       = module.security-group.security_group_arn
}

output "name" {
  description = "The computed name of the security group."
  value       = module.security-group.security_group_name
}
