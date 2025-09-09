terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.38.0"
    }
  }
  required_version = ">= 1.13"
}

variable "compute_environment_allocation_strategy" {
  type        = string
  description = "Allocation strategy for Batch Compute environment (BEST_FIT, BEST_FIT_PROGRESSIVE, SPOT_CAPACITY_OPTIMIZED) "
  default     = "SPOT_CAPACITY_OPTIMIZED"

}

variable "compute_environment_max_vcpus" {
  type        = number
  description = "Maximum VCPUs for Batch Compute Environment [16-96]"
}

variable "compute_environment_instance_types" {
  type        = list(string)
  description = "The instance types available for the compute environment as a comma-separated list"
  default     = [""]
}

variable "resource_prefix" {
  type        = string
  description = "Prefix given to all AWS resources to differentiate between applications. example ="
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}
