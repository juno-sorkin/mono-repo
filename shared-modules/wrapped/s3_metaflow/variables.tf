# shared-modules/wrapped/s3_metaflow/variables.tf

variable "bucket_name" {
  description = "The desired name for the S3 bucket."
  type        = string
}

variable "job_role_arn" {
  description = "The ARN of the IAM role used by Metaflow jobs, which needs access to this bucket."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the Metaflow jobs will run. This is used to restrict S3 access."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the S3 bucket resource."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed."
  type        = bool
  default     = false
}
