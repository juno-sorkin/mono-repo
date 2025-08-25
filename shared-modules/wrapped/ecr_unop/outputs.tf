# shared-modules/wrapped/ecr_unop/outputs.tf

output "repository_url" {
  description = "The URL of the repository, used by Docker clients and CI/CD systems."
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "The ARN of the repository, used for IAM policies."
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "The name of the repository."
  value       = module.ecr.repository_name
}

output "repository_registry_id" {
  description = "The AWS account ID (registry ID) where the repository lives."
  value       = module.ecr.repository_registry_id
}
