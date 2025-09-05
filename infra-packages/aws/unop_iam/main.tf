# infra-packages/aws/iam_metaflow/main.tf

locals {
  default_tags = {
    managed_by = "terraform"
  }

  # Common policy ARNs for Metaflow jobs
  job_policy_arns = concat([
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ], var.additional_job_policy_arns)

  # Instance role policy ARNs for Batch compute environments
  instance_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
}

# Batch Job Execution Role - Used by Metaflow tasks
module "batch_job_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.1"

  name        = "${var.name_prefix}-batch-job-role"
  description = "IAM role for Metaflow Batch jobs to access AWS services"

  # Trust policy for Batch and ECS tasks
  trust_policy_permissions = {
    "AllowECSTasksToAssumeRole" = {
      principals = [{
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
      }]
      actions = ["sts:AssumeRole"]
    }
  }

  # Convert policy ARNs to the expected map format
  policies = {
    for i, arn in local.job_policy_arns : "policy_${i}" => arn
  }

  # Custom inline policy for additional S3/ECR permissions if needed
  inline_policy_permissions = var.custom_job_policy_statements

  tags = merge(local.default_tags, var.tags)
}

# Batch Service Role - Used by AWS Batch service
module "batch_service_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.1"

  name        = "${var.name_prefix}-batch-service-role"
  description = "IAM service role for AWS Batch to manage compute environments"

  # Trust policy for Batch service
  trust_policy_permissions = {
    "AllowBatchServiceToAssumeRole" = {
      principals = [{
        type        = "Service"
        identifiers = ["batch.amazonaws.com"]
      }]
      actions = ["sts:AssumeRole"]
    }
  }

  policies = {
    batch_service_role = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
  }

  tags = merge(local.default_tags, var.tags)
}

# EC2 Instance Role - Used by EC2 instances in Batch compute environments
module "batch_instance_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.1"

  name                    = "${var.name_prefix}-batch-instance-role"
  description             = "IAM role for EC2 instances in Batch compute environments"
  create_instance_profile = true

  # Trust policy for EC2 service
  trust_policy_permissions = {
    "AllowEC2InstancesToAssumeRole" = {
      principals = [{
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }]
      actions = ["sts:AssumeRole"]
    }
  }

  policies = {
    for i, arn in local.instance_policy_arns : "policy_${i}" => arn
  }

  tags = merge(local.default_tags, var.tags)
}

# Spot Fleet Role - Used for Spot instances in Batch (optional)
module "spot_fleet_role" {
  count = var.enable_spot_fleet_role ? 1 : 0 #fix this redarted config

  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.2.0"


  name        = "${var.name_prefix}-spot-fleet-role"
  description = "IAM role for EC2 Spot Fleet requests in Batch"

  # Trust policy for Spot Fleet service
  trust_policy_permissions = {
    "AllowSpotFleetToAssumeRole" = {
      principals = [{
        type        = "Service"
        identifiers = ["spotfleet.amazonaws.com"]
      }]
      actions = ["sts:AssumeRole"]
    }
  }

  policies = {
    spot_fleet_tagging_role = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
  }

  tags = merge(local.default_tags, var.tags)
}
