# infra-packages/aws/batch_metaflow/outputs.tf

# Compute Environments
output "compute_environments" {
  description = "Map of all compute environments created and their attributes."
  value       = module.batch.compute_environments
}

output "ondemand_compute_environment_arn" {
  description = "ARN of the On-Demand compute environment."
  value       = module.batch.compute_environments["ondemand"].arn
}

output "spot_compute_environment_arn" {
  description = "ARN of the Spot compute environment. Only available if enable_spot_compute_environment is true."
  value       = var.enable_spot_compute_environment ? module.batch.compute_environments["spot"].arn : null
}

output "gpu_compute_environment_arn" {
  description = "ARN of the GPU compute environment. Only available if enable_gpu_compute_environment is true."
  value       = var.enable_gpu_compute_environment ? module.batch.compute_environments["gpu"].arn : null
}

# Job Queues
output "job_queues" {
  description = "Map of all job queues created and their attributes."
  value       = module.batch.job_queues
}

output "default_job_queue_arn" {
  description = "ARN of the default job queue. Use this for Metaflow configuration."
  value       = module.batch.job_queues["default"].arn
}

output "default_job_queue_name" {
  description = "Name of the default job queue. Use this for Metaflow configuration."
  value       = module.batch.job_queues["default"].name
}

output "gpu_job_queue_arn" {
  description = "ARN of the GPU job queue. Only available if enable_gpu_compute_environment is true."
  value       = var.enable_gpu_compute_environment ? module.batch.job_queues["gpu"].arn : null
}

output "gpu_job_queue_name" {
  description = "Name of the GPU job queue. Only available if enable_gpu_compute_environment is true."
  value       = var.enable_gpu_compute_environment ? module.batch.job_queues["gpu"].name : null
}

# Job Definitions
output "job_definitions" {
  description = "Map of all job definitions created and their attributes."
  value       = module.batch.job_definitions
}

output "default_job_definition_arn" {
  description = "ARN of the default job definition."
  value       = module.batch.job_definitions["metaflow_default"].arn
}

output "default_job_definition_name" {
  description = "Name of the default job definition."
  value       = module.batch.job_definitions["metaflow_default"].name
}

# Metaflow Configuration Outputs
output "metaflow_batch_job_queue" {
  description = "The job queue name to use in Metaflow configuration."
  value       = module.batch.job_queues["default"].name
}

output "metaflow_batch_job_definition" {
  description = "The job definition ARN to use in Metaflow configuration."
  value       = module.batch.job_definitions["metaflow_default"].arn
}
