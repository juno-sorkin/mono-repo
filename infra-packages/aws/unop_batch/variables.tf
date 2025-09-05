# infra-packages/aws/batch_metaflow/variables.tf

variable "name_prefix" {
  description = "A mandatory prefix used for naming all Batch resources (e.g., metaflow-prod, data-science-dev)."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Batch compute environments. Use public subnets from vpc_metaflow module."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to Batch compute environments."
  type        = list(string)
}

variable "job_role_arn" {
  description = "ARN of the IAM role for Batch jobs. Use batch_job_role_arn from iam_metaflow module."
  type        = string
}

variable "instance_profile_arn" {
  description = "ARN of the EC2 instance profile for Batch compute environments. Use batch_instance_profile_arn from iam_metaflow module."
  type        = string
}

variable "service_role_arn" {
  description = "ARN of the Batch service role. Use batch_service_role_arn from iam_metaflow module."
  type        = string
}


# never have this module create its own IAM roles, and dont confuse this var with the output of the public module
variable "spot_fleet_role_arn" {
  description = "ARN of the Spot Fleet role for Spot instances. Use spot_fleet_role_arn from iam_metaflow module"
  type        = string
  default     = null
}

variable "max_vcpus" {
  description = "Maximum number of vCPUs for the compute environment. Controls the maximum scale of your Batch jobs."
  type        = number
  default     = 16
}

variable "instance_types" {
  description = "List of EC2 instance types for Batch compute environments. Optimized for general-purpose workloads."
  type        = list(string)
  default     = ["c5.xlarge", "c5.2xlarge", "c5.4xlarge"]
}

variable "enable_spot_compute_environment" {
  description = "Whether to create a Spot compute environment for cost savings. Recommended for non-critical workloads."
  type        = bool
  default     = true
}

variable "spot_bid_percentage" {
  description = "The maximum percentage of On-Demand pricing to pay for Spot instances (1-100)."
  type        = number
  default     = 50
}

variable "enable_gpu_compute_environment" {
  description = "Whether to create a GPU-enabled compute environment for ML workloads."
  type        = bool
  default     = false
}

variable "gpu_instance_types" {
  description = "List of GPU-enabled EC2 instance types for ML workloads."
  type        = list(string)
  default     = ["g5.xlarge", "p4d.24xlarge"]
}

variable "gpu_max_vcpus" {
  description = "Maximum number of vCPUs for the GPU compute environment."
  type        = number
  default     = 32
}

variable "default_container_image" {
  description = "Default container image for Metaflow jobs. Uses AWS Deep Learning Container by default. pull from public docker registry or dlc, not custom ecr"
  type        = string
}

variable "tags" {
  description = "A map of AWS tags to apply to all Batch resources for cost allocation and identification."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs configuration."
  type        = string
  default     = "us-east-2"
}
