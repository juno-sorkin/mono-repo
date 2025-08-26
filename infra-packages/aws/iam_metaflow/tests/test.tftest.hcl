# Test file for iam_metaflow module

variables {
  name_prefix = "test-metaflow"
  tags = {
    Environment = "test"
    Owner       = "terraform-test"
  }
}

# Mock the AWS provider to prevent API calls
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      id   = "mock-policy-document"
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn                   = "arn:aws:iam::123456789012:role/test-role"
      assume_role_policy    = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
      create_date           = "2024-01-01T00:00:00Z"
      description           = "Test IAM role"
      force_detach_policies = false
      id                    = "test-role"
      managed_policy_arns   = []
      max_session_duration  = 3600
      name                  = "test-role"
      name_prefix           = null
      path                  = "/"
      permissions_boundary  = null
      tags                  = {}
      tags_all              = {}
      unique_id             = "AROATEST123456789"
    }
  }

  mock_resource "aws_iam_role_policy_attachment" {
    defaults = {
      id         = "test-role-policy-attachment"
      policy_arn = "arn:aws:iam::aws:policy/TestPolicy"
      role       = "test-role"
    }
  }

  mock_resource "aws_iam_instance_profile" {
    defaults = {
      arn         = "arn:aws:iam::123456789012:instance-profile/test-profile"
      create_date = "2024-01-01T00:00:00Z"
      id          = "test-profile"
      name        = "test-profile"
      name_prefix = null
      path        = "/"
      role        = "test-role"
      tags        = {}
      tags_all    = {}
      unique_id   = "AIPATEST123456789"
    }
  }

  mock_resource "aws_iam_role_policy" {
    defaults = {
      id     = "test-role:test-policy"
      name   = "test-policy"
      policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
      role   = "test-role"
    }
  }
}

# Test basic functionality with minimal configuration
run "basic_iam_roles_creation" {
  command = plan

  assert {
    condition     = length(keys(module.batch_job_role)) > 0
    error_message = "Batch job role module should be created"
  }

  assert {
    condition     = length(keys(module.batch_service_role)) > 0
    error_message = "Batch service role module should be created"
  }

  assert {
    condition     = length(keys(module.batch_instance_role)) > 0
    error_message = "Batch instance role module should be created"
  }

  assert {
    condition     = length(module.spot_fleet_role) == 0
    error_message = "Spot fleet role should not be created when enable_spot_fleet_role is false"
  }
}

# Test with additional job policy ARNs
run "additional_job_policies" {
  command = plan

  variables {
    additional_job_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
      "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
    ]
  }

  assert {
    condition     = contains(local.job_policy_arns, "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess")
    error_message = "Additional job policy ARNs should be included in local.job_policy_arns"
  }

  assert {
    condition     = contains(local.job_policy_arns, "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess")
    error_message = "Additional job policy ARNs should be included in local.job_policy_arns"
  }

  assert {
    condition     = length(local.job_policy_arns) == 5
    error_message = "Should have 3 default + 2 additional policy ARNs"
  }
}

# Test with custom inline policy statements
run "custom_job_policy_statements" {
  command = plan

  variables {
    custom_job_policy_statements = {
      custom_s3_access = {
        sid       = "CustomS3Access"
        actions   = ["s3:GetObject", "s3:PutObject"]
        resources = ["arn:aws:s3:::my-bucket/*"]
        effect    = "Allow"
      }
    }
  }

  assert {
    condition     = var.custom_job_policy_statements != null
    error_message = "Custom job policy statements should be set"
  }

  assert {
    condition     = length(var.custom_job_policy_statements) == 1
    error_message = "Should have exactly one custom policy statement"
  }
}

# Test with spot fleet role enabled
run "spot_fleet_role_enabled" {
  command = plan

  variables {
    enable_spot_fleet_role = true
  }

  assert {
    condition     = var.enable_spot_fleet_role == true
    error_message = "Spot fleet role should be enabled"
  }

  assert {
    condition     = length(module.spot_fleet_role) == 1
    error_message = "Spot fleet role should be created when enabled"
  }
}

# Test module configuration structure
run "module_configuration_validation" {
  command = plan

  assert {
    condition     = length(keys(module.batch_job_role)) > 0
    error_message = "Batch job role module should be configured"
  }

  assert {
    condition     = length(keys(module.batch_service_role)) > 0
    error_message = "Batch service role module should be configured"
  }

  assert {
    condition     = length(keys(module.batch_instance_role)) > 0
    error_message = "Batch instance role module should be configured"
  }
}

# Test tag merging
run "tag_merging" {
  command = plan

  variables {
    tags = {
      Environment = "test"
      Project     = "metaflow-test"
    }
  }

  assert {
    condition     = local.default_tags.managed_by == "terraform"
    error_message = "Default tags should include managed_by = terraform"
  }

  assert {
    condition     = local.default_tags.project == "metaflow"
    error_message = "Default tags should include project = metaflow"
  }
}

# Test name prefix usage and variable validation
run "variable_validation" {
  command = plan

  variables {
    name_prefix = "custom-prefix"
    tags = {
      Environment = "test"
      Team        = "platform"
    }
  }

  assert {
    condition     = var.name_prefix == "custom-prefix"
    error_message = "Name prefix should be set correctly"
  }

  assert {
    condition     = var.tags["Environment"] == "test"
    error_message = "Environment tag should be set correctly"
  }

  assert {
    condition     = var.tags["Team"] == "platform"
    error_message = "Team tag should be set correctly"
  }

  assert {
    condition     = var.enable_spot_fleet_role == false
    error_message = "Spot fleet role should be disabled by default"
  }
}

# Test default policy ARNs
run "default_policy_arns" {
  command = plan

  assert {
    condition     = contains(local.job_policy_arns, "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess")
    error_message = "Should include CloudWatch Logs policy by default"
  }

  assert {
    condition     = contains(local.job_policy_arns, "arn:aws:iam::aws:policy/AmazonS3FullAccess")
    error_message = "Should include S3 Full Access policy by default"
  }

  assert {
    condition     = contains(local.job_policy_arns, "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnlyAccess")
    error_message = "Should include ECR Read Only policy by default"
  }

  assert {
    condition     = contains(local.instance_policy_arns, "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role")
    error_message = "Should include ECS for EC2 service role policy for instances"
  }

  assert {
    condition     = length(local.job_policy_arns) == 3
    error_message = "Should have exactly 3 default job policy ARNs"
  }

  assert {
    condition     = length(local.instance_policy_arns) == 1
    error_message = "Should have exactly 1 instance policy ARN"
  }
}

# Test edge cases and empty configurations
run "edge_cases" {
  command = plan

  variables {
    name_prefix                  = "edge-test"
    additional_job_policy_arns   = []
    custom_job_policy_statements = null
    enable_spot_fleet_role       = false
    tags                         = {}
  }

  assert {
    condition     = length(var.additional_job_policy_arns) == 0
    error_message = "Additional job policy ARNs should be empty array"
  }

  assert {
    condition     = var.custom_job_policy_statements == null
    error_message = "Custom job policy statements should be null"
  }

  assert {
    condition     = length(var.tags) == 0
    error_message = "Tags should be empty map"
  }

  assert {
    condition     = length(local.job_policy_arns) == 3
    error_message = "Should still have 3 default job policies even with empty additional policies"
  }
}
