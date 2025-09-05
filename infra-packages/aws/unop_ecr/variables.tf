# infra-packages/aws/ecr_unop/variables.tf

variable "repository_name" {
  description = "The name of the repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. Defaults to `IMMUTABLE`"
  type        = string
  default     = "IMMUTABLE"
}

variable "force_delete" {
  description = "If `true`, will delete the repository even if it contains images. Defaults to `false`"
  type        = bool
  default     = false
}

variable "job_role_arn" {
  description = "The ARN of the IAM role that will be granted read/write access to the ECR repository. If null, no repository policy will be attached."
  type        = string
  default     = null
}

variable "lifecycle_policy_json" {
  description = "The JSON lifecycle policy text. See https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_examples"
  type        = string
  default     = null
}

variable "attach_policy" {
  description = "Whether to create and attach the repository policy. This is used to break a dependency cycle during terraform plan."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
