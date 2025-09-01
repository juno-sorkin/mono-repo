# infra-packages/aws/s3_metaflow/outputs.tf

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_id" {
  description = "The name (id) of the S3 bucket."
  value       = module.s3_bucket.s3_bucket_id
}
