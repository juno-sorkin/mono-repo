# infra-packages/aws/iam_metaflow/outputs.tf

# Batch Job Role - Used by S3 and ECR modules for permissions
output "batch_job_role_arn" {
  description = "The ARN of the Batch job role. Use this for the job_role_arn variable in s3_metaflow and ecr_unop modules."
  value       = module.batch_job_role.arn
}

output "batch_job_role_name" {
  description = "The name of the Batch job role."
  value       = module.batch_job_role.name
}

# Batch Service Role - Used by AWS Batch module for compute environments
output "batch_service_role_arn" {
  description = "The ARN of the Batch service role. Use this for the service_role variable in AWS Batch compute environments."
  value       = module.batch_service_role.arn
}

output "batch_service_role_name" {
  description = "The name of the Batch service role."
  value       = module.batch_service_role.name
}

# EC2 Instance Role - Used by AWS Batch module for EC2 compute environments
output "batch_instance_role_arn" {
  description = "The ARN of the EC2 instance role. Use this for the instance_role variable in AWS Batch compute environments."
  value       = module.batch_instance_role.arn
}

output "batch_instance_role_name" {
  description = "The name of the EC2 instance role."
  value       = module.batch_instance_role.name
}

output "batch_instance_profile_arn" {
  description = "The ARN of the EC2 instance profile. Use this for EC2 instances in Batch compute environments."
  value       = module.batch_instance_role.instance_profile_arn
}

output "batch_instance_profile_name" {
  description = "The name of the EC2 instance profile."
  value       = module.batch_instance_role.instance_profile_name
}

# Spot Fleet Role - Optional, used for Spot instances in Batch
output "spot_fleet_role_arn" {
  description = "The ARN of the Spot Fleet role. Only available if enable_spot_fleet_role is true."
  value       = var.enable_spot_fleet_role ? module.spot_fleet_role[0].arn : null
}

output "spot_fleet_role_name" {
  description = "The name of the Spot Fleet role. Only available if enable_spot_fleet_role is true."
  value       = var.enable_spot_fleet_role ? module.spot_fleet_role[0].name : null
}
