# shared-modules/wrapped/iam_metaflow/variables.tf

variable "name_prefix" {
  description = "A prefix used for naming all IAM resources (e.g., 'metaflow-prod', 'metaflow-dev')"
  type        = string
}

variable "additional_job_policy_arns" {
  description = "Additional managed policy ARNs to attach to the Batch job role beyond the default CloudWatch, S3, and ECR policies"
  type        = list(string)
  default     = []
}

variable "custom_job_policy_statements" {
  description = "Optional custom inline policy statements for the Batch job role. Use this for specific permissions not covered by managed policies."
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string, "Allow")
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

variable "enable_spot_fleet_role" {
  description = "Whether to create a Spot Fleet role for Batch compute environments using Spot instances"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all IAM resources"
  type        = map(string)
  default     = {}
}
