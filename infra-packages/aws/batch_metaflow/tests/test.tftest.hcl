# Test file for batch_metaflow module

variables {
  name_prefix                     = "test-batch"
  subnet_ids                      = ["subnet-12345678", "subnet-87654321"]
  security_group_ids              = ["sg-12345678"]
  job_role_arn                    = "arn:aws:iam::123456789012:role/MetaflowJobRole"
  instance_profile_arn            = "arn:aws:iam::123456789012:instance-profile/MetaflowInstanceProfile"
  service_role_arn                = "arn:aws:iam::123456789012:role/MetaflowServiceRole"
  default_container_image         = "public.ecr.aws/lambda/python:3.9"
  enable_spot_compute_environment = false
}

# Mock the AWS provider to prevent API calls
mock_provider "aws" {
  mock_resource "aws_batch_compute_environment" {
    defaults = {
      arn                      = "arn:aws:batch:us-east-1:123456789012:compute-environment/test-batch-ondemand"
      compute_environment_name = "test-batch-ondemand"
      ecs_cluster_arn          = "arn:aws:ecs:us-east-1:123456789012:cluster/test-batch-cluster"
      id                       = "test-batch-ondemand"
      service_role             = "arn:aws:iam::123456789012:role/MetaflowServiceRole"
      state                    = "ENABLED"
      status                   = "VALID"
      status_reason            = "ComputeEnvironment Healthy"
      tags                     = {}
      tags_all                 = {}
      type                     = "MANAGED"
    }
  }

  mock_resource "aws_batch_job_queue" {
    defaults = {
      arn      = "arn:aws:batch:us-east-1:123456789012:job-queue/test-batch-default"
      id       = "test-batch-default"
      name     = "test-batch-default"
      priority = 100
      state    = "ENABLED"
      tags     = {}
      tags_all = {}
    }
  }

  mock_resource "aws_batch_job_definition" {
    defaults = {
      arn      = "arn:aws:batch:us-east-1:123456789012:job-definition/test-batch-default:1"
      id       = "test-batch-default"
      name     = "test-batch-default"
      revision = 1
      tags     = {}
      tags_all = {}
      type     = "container"
    }
  }

  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn               = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/batch/test-batch"
      id                = "/aws/batch/test-batch"
      name              = "/aws/batch/test-batch"
      retention_in_days = 0
      tags              = {}
      tags_all          = {}
    }
  }
}

# Test basic Batch configuration with minimal required variables
run "basic_batch_configuration" {
  command = plan

  assert {
    condition     = var.name_prefix == "test-batch"
    error_message = "Name prefix should be set correctly"
  }

  assert {
    condition     = length(var.subnet_ids) == 2
    error_message = "Should have 2 subnet IDs"
  }

  assert {
    condition     = length(var.security_group_ids) == 1
    error_message = "Should have 1 security group ID"
  }

  assert {
    condition     = var.max_vcpus == 16
    error_message = "Default max_vcpus should be 16"
  }

  assert {
    condition     = var.enable_spot_compute_environment == false
    error_message = "Spot compute environment should be disabled for basic test"
  }

  assert {
    condition     = var.enable_gpu_compute_environment == false
    error_message = "Default enable_gpu_compute_environment should be false"
  }

  assert {
    condition     = var.spot_bid_percentage == 50
    error_message = "Default spot_bid_percentage should be 50"
  }

  assert {
    condition     = length(var.instance_types) == 3
    error_message = "Default instance_types should have 3 types"
  }

  assert {
    condition     = length(keys(module.batch)) > 0
    error_message = "Batch module should be configured"
  }
}

# Test Batch with custom compute configuration
run "custom_compute_configuration" {
  command = plan

  variables {
    name_prefix                     = "batch-custom"
    subnet_ids                      = ["subnet-12345678"]
    security_group_ids              = ["sg-12345678", "sg-87654321"]
    job_role_arn                    = "arn:aws:iam::123456789012:role/MetaflowJobRole"
    instance_profile_arn            = "arn:aws:iam::123456789012:instance-profile/MetaflowInstanceProfile"
    service_role_arn                = "arn:aws:iam::123456789012:role/MetaflowServiceRole"
    default_container_image         = "public.ecr.aws/lambda/python:3.10"
    max_vcpus                       = 32
    instance_types                  = ["m5.large", "m5.xlarge", "c5.large"]
    enable_spot_compute_environment = false
    spot_bid_percentage             = 70
    tags = {
      Environment = "test"
      Project     = "metaflow"
    }
  }

  assert {
    condition     = var.max_vcpus == 32
    error_message = "Custom max_vcpus should be 32"
  }

  assert {
    condition     = var.spot_bid_percentage == 70
    error_message = "Custom spot_bid_percentage should be 70"
  }

  assert {
    condition     = length(var.instance_types) == 3
    error_message = "Custom instance_types should have 3 types"
  }

  assert {
    condition     = contains(var.instance_types, "m5.large")
    error_message = "Should include m5.large instance type"
  }

  assert {
    condition     = var.tags["Environment"] == "test"
    error_message = "Environment tag should be test"
  }
}

# Test Batch with GPU compute environment enabled
run "gpu_compute_environment" {
  command = plan

  variables {
    name_prefix                     = "batch-gpu"
    subnet_ids                      = ["subnet-12345678"]
    security_group_ids              = ["sg-12345678"]
    job_role_arn                    = "arn:aws:iam::123456789012:role/MetaflowJobRole"
    instance_profile_arn            = "arn:aws:iam::123456789012:instance-profile/MetaflowInstanceProfile"
    service_role_arn                = "arn:aws:iam::123456789012:role/MetaflowServiceRole"
    default_container_image         = "public.ecr.aws/lambda/python:3.9"
    enable_spot_compute_environment = false
    enable_gpu_compute_environment  = true
    gpu_max_vcpus                   = 64
    gpu_instance_types              = ["g4dn.xlarge", "g4dn.2xlarge", "p3.2xlarge"]
    tags = {
      Environment = "production"
      GPU         = "enabled"
    }
  }

  assert {
    condition     = var.enable_gpu_compute_environment == true
    error_message = "GPU compute environment should be enabled"
  }

  assert {
    condition     = var.gpu_max_vcpus == 64
    error_message = "GPU max_vcpus should be 64"
  }

  assert {
    condition     = length(var.gpu_instance_types) == 3
    error_message = "Should have 3 GPU instance types"
  }

  assert {
    condition     = contains(var.gpu_instance_types, "g4dn.xlarge")
    error_message = "Should include g4dn.xlarge GPU instance type"
  }
}

# Test Batch with Spot Fleet role configured
run "spot_fleet_configuration" {
  command = plan

  variables {
    name_prefix                     = "batch-spot"
    subnet_ids                      = ["subnet-12345678"]
    security_group_ids              = ["sg-12345678"]
    job_role_arn                    = "arn:aws:iam::123456789012:role/MetaflowJobRole"
    instance_profile_arn            = "arn:aws:iam::123456789012:instance-profile/MetaflowInstanceProfile"
    service_role_arn                = "arn:aws:iam::123456789012:role/MetaflowServiceRole"
    spot_fleet_role_arn             = "arn:aws:iam::123456789012:role/MetaflowSpotFleetRole"
    default_container_image         = "public.ecr.aws/lambda/python:3.9"
    enable_spot_compute_environment = true
    spot_bid_percentage             = 80
  }

  assert {
    condition     = var.spot_fleet_role_arn == "arn:aws:iam::123456789012:role/MetaflowSpotFleetRole"
    error_message = "Spot Fleet role ARN should be set"
  }

  assert {
    condition     = var.spot_bid_percentage == 80
    error_message = "Spot bid percentage should be 80"
  }

  assert {
    condition     = var.enable_spot_compute_environment == true
    error_message = "Spot compute environment should be enabled"
  }
}

# Test ARN validation for IAM roles
run "iam_arn_validation" {
  command = plan

  variables {
    name_prefix                     = "batch-arn"
    subnet_ids                      = ["subnet-12345678"]
    security_group_ids              = ["sg-12345678"]
    job_role_arn                    = "arn:aws:iam::999888777666:role/MetaflowJobRole"
    instance_profile_arn            = "arn:aws:iam::999888777666:instance-profile/MetaflowInstanceProfile"
    service_role_arn                = "arn:aws:iam::999888777666:role/MetaflowServiceRole"
    spot_fleet_role_arn             = "arn:aws:iam::999888777666:role/MetaflowSpotFleetRole"
    default_container_image         = "public.ecr.aws/lambda/python:3.9"
    enable_spot_compute_environment = true
  }

  assert {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.job_role_arn))
    error_message = "Job role ARN should be in valid AWS IAM role format"
  }

  assert {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:instance-profile/.+$", var.instance_profile_arn))
    error_message = "Instance profile ARN should be in valid AWS IAM instance profile format"
  }

  assert {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.service_role_arn))
    error_message = "Service role ARN should be in valid AWS IAM role format"
  }

  assert {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.spot_fleet_role_arn))
    error_message = "Spot Fleet role ARN should be in valid AWS IAM role format"
  }
}

# Test variable types and constraints
run "variable_types_validation" {
  command = plan

  variables {
    name_prefix                     = "batch-type"
    subnet_ids                      = ["subnet-12345678"]
    security_group_ids              = ["sg-12345678"]
    job_role_arn                    = "arn:aws:iam::123456789012:role/MetaflowJobRole"
    instance_profile_arn            = "arn:aws:iam::123456789012:instance-profile/MetaflowInstanceProfile"
    service_role_arn                = "arn:aws:iam::123456789012:role/MetaflowServiceRole"
    default_container_image         = "public.ecr.aws/lambda/python:3.9"
    enable_spot_compute_environment = false
    enable_gpu_compute_environment  = false
    spot_fleet_role_arn             = null
    tags                            = {}
  }

  assert {
    condition     = can(tostring(var.name_prefix))
    error_message = "Name prefix should be a string"
  }

  assert {
    condition     = can(tolist(var.subnet_ids))
    error_message = "Subnet IDs should be a list"
  }

  assert {
    condition     = can(tobool(var.enable_spot_compute_environment))
    error_message = "Enable spot compute environment should be a boolean"
  }

  assert {
    condition     = can(tonumber(var.max_vcpus))
    error_message = "Max vCPUs should be a number"
  }

  assert {
    condition     = can(tomap(var.tags))
    error_message = "Tags should be a map"
  }

  assert {
    condition     = var.spot_fleet_role_arn == null
    error_message = "Null spot fleet role ARN should be allowed"
  }

  assert {
    condition     = length(keys(var.tags)) == 0
    error_message = "Empty tags should be allowed"
  }
}

# Test local values and tag merging
run "local_values_validation" {
  command = plan

  variables {
    name_prefix                     = "batch-local"
    subnet_ids                      = ["subnet-12345678"]
    security_group_ids              = ["sg-12345678"]
    job_role_arn                    = "arn:aws:iam::123456789012:role/MetaflowJobRole"
    instance_profile_arn            = "arn:aws:iam::123456789012:instance-profile/MetaflowInstanceProfile"
    service_role_arn                = "arn:aws:iam::123456789012:role/MetaflowServiceRole"
    default_container_image         = "public.ecr.aws/lambda/python:3.9"
    enable_spot_compute_environment = false
    tags = {
      Environment = "test"
      Custom      = "value"
    }
  }

  assert {
    condition     = local.common_tags.Terraform == "true"
    error_message = "Common tags should include Terraform = true"
  }

  assert {
    condition     = local.common_tags.Module == "batch_metaflow"
    error_message = "Common tags should include Module = batch_metaflow"
  }

  assert {
    condition     = local.base_compute_resources.type == "EC2"
    error_message = "Base compute resources should be EC2 type"
  }

  assert {
    condition     = local.base_compute_resources.min_vcpus == 0
    error_message = "Base compute resources should have min_vcpus = 0"
  }
}
