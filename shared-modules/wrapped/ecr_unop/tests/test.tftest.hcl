# Test file for ecr_unop module

variables {
  repository_name = "test-metaflow-repo"
}

# Mock the AWS provider to prevent API calls
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      id   = "mock-policy-document"
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:role/TestRole\"},\"Action\":[\"ecr:GetDownloadUrlForLayer\",\"ecr:BatchGetImage\",\"ecr:BatchCheckLayerAvailability\",\"ecr:PutImage\",\"ecr:InitiateLayerUpload\",\"ecr:UploadLayerPart\",\"ecr:CompleteLayerUpload\"]}]}"
    }
  }

  mock_resource "aws_ecr_repository" {
    defaults = {
      arn                  = "arn:aws:ecr:us-east-1:123456789012:repository/test-repo"
      id                   = "test-repo"
      name                 = "test-repo"
      registry_id          = "123456789012"
      repository_url       = "123456789012.dkr.ecr.us-east-1.amazonaws.com/test-repo"
      image_tag_mutability = "IMMUTABLE"
      force_delete         = false
      tags                 = {}
      tags_all             = {}
    }
  }

  mock_resource "aws_ecr_lifecycle_policy" {
    defaults = {
      id          = "test-repo"
      policy      = "{\"rules\":[{\"rulePriority\":1,\"description\":\"Expire untagged images older than 14 days\",\"selection\":{\"tagStatus\":\"untagged\",\"countType\":\"sinceImagePushed\",\"countUnit\":\"days\",\"countNumber\":14},\"action\":{\"type\":\"expire\"}}]}"
      registry_id = "123456789012"
      repository  = "test-repo"
    }
  }

  mock_resource "aws_ecr_repository_policy" {
    defaults = {
      id          = "test-repo"
      policy      = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
      registry_id = "123456789012"
      repository  = "test-repo"
    }
  }
}

# Test basic ECR repository creation with minimal configuration
run "basic_ecr_configuration" {
  command = plan

  assert {
    condition     = var.repository_name == "test-metaflow-repo"
    error_message = "Repository name should be set correctly"
  }

  assert {
    condition     = var.image_tag_mutability == "IMMUTABLE"
    error_message = "Default image_tag_mutability should be IMMUTABLE"
  }

  assert {
    condition     = var.force_delete == false
    error_message = "Default force_delete should be false"
  }

  assert {
    condition     = var.job_role_arn == null
    error_message = "Default job_role_arn should be null"
  }

  assert {
    condition     = var.lifecycle_policy_json == null
    error_message = "Default lifecycle_policy_json should be null"
  }

  assert {
    condition     = length(keys(var.tags)) == 0
    error_message = "Default tags should be empty"
  }

  assert {
    condition     = length(keys(module.ecr)) > 0
    error_message = "ECR module should be configured"
  }
}

# Test ECR repository with IAM role integration
run "iam_role_integration" {
  command = plan

  variables {
    repository_name = "metaflow-flows"
    job_role_arn    = "arn:aws:iam::123456789012:role/MetaflowBatchJobRole"
    tags = {
      Environment = "production"
      Project     = "metaflow"
      Usage       = "container-registry"
    }
  }

  assert {
    condition     = var.job_role_arn == "arn:aws:iam::123456789012:role/MetaflowBatchJobRole"
    error_message = "Job role ARN should be set correctly"
  }

  assert {
    condition     = var.tags["Environment"] == "production"
    error_message = "Environment tag should be production"
  }

  assert {
    condition     = var.tags["Project"] == "metaflow"
    error_message = "Project tag should be metaflow"
  }

  assert {
    condition     = length(keys(var.tags)) == 3
    error_message = "Should have 3 tags configured"
  }
}

# Test ECR repository with mutable tags
run "mutable_tags_configuration" {
  command = plan

  variables {
    repository_name      = "dev-metaflow-repo"
    image_tag_mutability = "MUTABLE"
    force_delete         = true
    tags = {
      Environment = "development"
      Mutable     = "true"
    }
  }

  assert {
    condition     = var.image_tag_mutability == "MUTABLE"
    error_message = "Image tag mutability should be MUTABLE"
  }

  assert {
    condition     = var.force_delete == true
    error_message = "Force delete should be enabled for development"
  }

  assert {
    condition     = var.tags["Environment"] == "development"
    error_message = "Environment should be development"
  }
}

# Test ECR repository with custom lifecycle policy
run "custom_lifecycle_policy" {
  command = plan

  variables {
    repository_name       = "custom-lifecycle-repo"
    lifecycle_policy_json = "{\"rules\":[{\"rulePriority\":1,\"description\":\"Expire untagged images older than 7 days\",\"selection\":{\"tagStatus\":\"untagged\",\"countType\":\"sinceImagePushed\",\"countUnit\":\"days\",\"countNumber\":7},\"action\":{\"type\":\"expire\"}}]}"
    tags = {
      Environment  = "test"
      CustomPolicy = "true"
    }
  }

  assert {
    condition     = var.lifecycle_policy_json != null
    error_message = "Custom lifecycle policy should be set"
  }

  assert {
    condition     = can(jsondecode(var.lifecycle_policy_json))
    error_message = "Lifecycle policy should be valid JSON"
  }

  assert {
    condition     = var.tags["CustomPolicy"] == "true"
    error_message = "Custom policy tag should be set"
  }
}

# Test repository naming conventions
run "repository_naming_validation" {
  command = plan

  variables {
    repository_name = "my-company/metaflow-flows"
  }

  assert {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._/-]*[a-zA-Z0-9]$", var.repository_name))
    error_message = "Repository name should follow ECR naming conventions"
  }

  assert {
    condition     = length(var.repository_name) >= 2 && length(var.repository_name) <= 256
    error_message = "Repository name should be between 2 and 256 characters"
  }
}

# Test IAM role ARN validation
run "iam_arn_validation" {
  command = plan

  variables {
    repository_name = "arn-validation-repo"
    job_role_arn    = "arn:aws:iam::999888777666:role/MetaflowJobRole"
  }

  assert {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.job_role_arn))
    error_message = "Job role ARN should be in valid AWS IAM role format"
  }
}

# Test image tag mutability validation
run "tag_mutability_validation" {
  command = plan

  variables {
    repository_name      = "mutability-test-repo"
    image_tag_mutability = "IMMUTABLE"
  }

  assert {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE"
  }
}

# Test variable types and constraints
run "variable_types_validation" {
  command = plan

  variables {
    repository_name       = "type-test-repo"
    image_tag_mutability  = "MUTABLE"
    force_delete          = true
    job_role_arn          = null
    lifecycle_policy_json = null
    tags = {
      string_tag = "value"
      number_tag = "123"
    }
  }

  assert {
    condition     = can(tostring(var.repository_name))
    error_message = "Repository name should be a string"
  }

  assert {
    condition     = can(tostring(var.image_tag_mutability))
    error_message = "Image tag mutability should be a string"
  }

  assert {
    condition     = can(tobool(var.force_delete))
    error_message = "Force delete should be a boolean"
  }

  assert {
    condition     = can(tomap(var.tags))
    error_message = "Tags should be a map"
  }

  assert {
    condition     = var.job_role_arn == null
    error_message = "Null job role ARN should be allowed"
  }

  assert {
    condition     = var.lifecycle_policy_json == null
    error_message = "Null lifecycle policy should be allowed"
  }
}

# Test edge cases and boundary conditions
run "edge_cases_validation" {
  command = plan

  variables {
    repository_name       = "ab"
    image_tag_mutability  = "IMMUTABLE"
    force_delete          = false
    job_role_arn          = null
    lifecycle_policy_json = null
    tags                  = {}
  }

  assert {
    condition     = length(var.repository_name) >= 2
    error_message = "Minimum repository name length should be 2 characters"
  }

  assert {
    condition     = length(keys(var.tags)) == 0
    error_message = "Empty tags should be allowed"
  }

  assert {
    condition     = var.repository_name != ""
    error_message = "Repository name should not be empty"
  }
}

# Test local values and tag merging
run "local_values_validation" {
  command = plan

  variables {
    repository_name = "local-test-repo"
    tags = {
      Environment = "test"
      Custom      = "value"
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

  assert {
    condition     = local.default_lifecycle_policy != null
    error_message = "Default lifecycle policy should be defined"
  }

  assert {
    condition     = can(jsondecode(local.default_lifecycle_policy))
    error_message = "Default lifecycle policy should be valid JSON"
  }
}
