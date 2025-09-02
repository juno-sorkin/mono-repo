# services/qwen_ft/infra/outputs.tf

output "metaflow_batch_job_queue" {
  description = "The job queue name to use in Metaflow configuration."
  value       = module.batch.metaflow_batch_job_queue
}

output "metaflow_batch_job_definition" {
  description = "The job definition ARN to use in Metaflow configuration."
  value       = module.batch.metaflow_batch_job_definition
}

output "s3_bucket_id" {
  description = "The name of the S3 bucket for Metaflow data."
  value       = module.s3.s3_bucket_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for job container images."
  value       = module.ecr.repository_url
}

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}
