# infra-packages/aws/metaflow_batch/variables.tf


## Computation (batch)
variable "compute_environment_allocation_strategy" {
  type        = string
  description = "Allocation strategy for Batch Compute environment (BEST_FIT, BEST_FIT_PROGRESSIVE, SPOT_CAPACITY_OPTIMIZED) "
  default     = "SPOT_CAPACITY_OPTIMIZED"

}

variable "max_vcpu" {
  type        = number
  description = "Maximum VCPUs for Batch Compute Environment [16-96]"
}

variable "instance_types" {
  type        = list(string)
  description = "The instance types available for the compute environment as a comma-separated list (must be more than 1) e.g [local.cpu] or [local.small_gpu] or [local.large_gpu]"
}

variable "launch_template_http_endpoint" {
  type        = string
  description = "Whether the metadata service is available. Can be 'enabled' or 'disabled'"
  default     = "disabled"
}


## resource naming and tags
variable "resource_prefix" {
  type        = string
  description = "Prefix given to all AWS resources to differentiate between applications. example ="
}

variable "resource_suffix" {
  type =  string
  description = "string suffix for all resources"
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
  default = {
    "name" = "value"
  }
}

## vpc
variable "backup_subnet_1" { #derive from vpc
  
}

variable "backup_subnet_2" { #derive from vpc
  
}

variable "metaflow_vpc_id" { #derive from vpc
  
}
