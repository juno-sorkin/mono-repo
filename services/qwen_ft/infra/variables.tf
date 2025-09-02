# services/qwen_ft/infra/variables.tf

variable "name_prefix" {
  description = "A prefix for all resources created (e.g., 'qwen-ft-prod')."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "The single AWS Availability Zone into which all network resources will be deployed (e.g., us-east-2a)."
  type        = string
  default     = "us-east-2a"
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Metaflow data."
  type        = string
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository to create."
  type        = string
}

variable "ecr_attach_policy" {
  description = "Whether to attach the IAM policy to the ECR repository."
  type        = bool
  default     = true
}

variable "default_container_image" {
  description = "Default container image for Metaflow jobs. Uses AWS Deep Learning Container by default."
  type        = string
}

variable "enable_spot_fleet_role" {
  description = "Whether to create a Spot Fleet role for Batch compute environments using Spot instances."
  type        = bool
  default     = true
}

variable "enable_spot_compute_environment" {
  description = "Whether to create a Spot compute environment for cost savings."
  type        = bool
  default     = true
}

variable "spot_bid_percentage" {
  description = "The maximum percentage of On-Demand pricing to pay for Spot instances (1-100)."
  type        = number
  default     = 60
}

variable "max_vcpus" {
  description = "Maximum number of vCPUs for the default compute environment."
  type        = number
  default     = 32
}

variable "instance_types" {
  description = "List of EC2 instance types for the default compute environment."
  type        = list(string)
  default     = ["m5.large", "m5.xlarge", "c5.xlarge"]
}

variable "enable_gpu_compute_environment" {
  description = "Whether to create a GPU-enabled compute environment for ML workloads."
  type        = bool
  default     = true
}

variable "gpu_instance_types" {
  description = "List of GPU-enabled EC2 instance types for ML workloads."
  type        = list(string)
  default     = ["g4dn.xlarge", "g4dn.2xlarge"]
}

variable "gpu_max_vcpus" {
  description = "Maximum number of vCPUs for the GPU compute environment."
  type        = number
  default     = 64
}
