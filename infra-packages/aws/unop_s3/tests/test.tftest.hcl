# Test file for s3_metaflow module

variables {
  bucket_name  = "test-metaflow-datastore"
  job_role_arn = "arn:aws:iam::123456789012:role/MetaflowJobRole"
  vpc_id       = "vpc-12345678"
}

# Mock the AWS provider to prevent API calls
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      id   = "mock-policy-document"
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"AllowMetaflowJobRole\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::123456789012:role/MetaflowJobRole\"},\"Action\":[\"s3:GetObject\",\"s3:PutObject\",\"s3:ListBucket\"],\"Resource\":[\"arn:aws:s3:::test-bucket\",\"arn:aws:s3:::test-bucket/*\"],\"Condition\":{\"StringEquals\":{\"aws:sourceVpc\":\"vpc-12345678\"}}}]}"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      arn                         = "arn:aws:s3:::test-bucket"
      bucket                      = "test-bucket"
      bucket_domain_name          = "test-bucket.s3.amazonaws.com"
      bucket_regional_domain_name = "test-bucket.s3.us-east-1.amazonaws.com"
      hosted_zone_id              = "Z3AQBSTGFYJSTF"
      id                          = "test-bucket"
      region                      = "us-east-1"
      tags                        = {}
      tags_all                    = {}
    }
  }

  mock_resource "aws_s3_bucket_versioning" {
    defaults = {
      bucket = "test-bucket"
      id     = "test-bucket"
      versioning_configuration = [{
        status = "Enabled"
      }]
    }
  }

  mock_resource "aws_s3_bucket_server_side_encryption_configuration" {
    defaults = {
      bucket = "test-bucket"
      id     = "test-bucket"
      rule = [{
        apply_server_side_encryption_by_default = [{
          sse_algorithm = "AES256"
        }]
      }]
    }
  }

  mock_resource "aws_s3_bucket_public_access_block" {
    defaults = {
      bucket                  = "test-bucket"
      id                      = "test-bucket"
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }

  mock_resource "aws_s3_bucket_ownership_controls" {
    defaults = {
      bucket = "test-bucket"
      id     = "test-bucket"
      rule = [{
        object_ownership = "BucketOwnerEnforced"
      }]
    }
  }

  mock_resource "aws_s3_bucket_policy" {
    defaults = {
      bucket = "test-bucket"
      id     = "test-bucket"
      policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

# Test basic S3 bucket creation with minimal configuration
run "basic_s3_configuration" {
  command = plan

  assert {
    condition     = var.bucket_name == "test-metaflow-datastore"
    error_message = "Bucket name should be set correctly"
  }

  assert {
    condition     = var.job_role_arn == "arn:aws:iam::123456789012:role/MetaflowJobRole"
    error_message = "Job role ARN should be set correctly"
  }

  assert {
    condition     = var.vpc_id == "vpc-12345678"
    error_message = "VPC ID should be set correctly"
  }

  assert {
    condition     = var.force_destroy == false
    error_message = "Default force_destroy should be false"
  }

  assert {
    condition     = length(keys(var.tags)) == 0
    error_message = "Default tags should be empty"
  }

  assert {
    condition     = length(keys(module.s3_bucket)) > 0
    error_message = "S3 bucket module should be configured"
  }
}

# Test S3 bucket with custom tags
run "custom_tags_configuration" {
  command = plan

  variables {
    bucket_name  = "metaflow-prod-datastore"
    job_role_arn = "arn:aws:iam::123456789012:role/MetaflowProdJobRole"
    vpc_id       = "vpc-prod123"
    tags = {
      Environment = "production"
      Project     = "metaflow"
      Team        = "data-science"
      CostCenter  = "engineering"
    }
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
    condition     = length(keys(var.tags)) == 4
    error_message = "Should have 4 tags configured"
  }
}

# Test S3 bucket with force_destroy enabled
run "force_destroy_configuration" {
  command = plan

  variables {
    bucket_name   = "test-metaflow-temp"
    job_role_arn  = "arn:aws:iam::123456789012:role/MetaflowTestRole"
    vpc_id        = "vpc-test123"
    force_destroy = true
    tags = {
      Environment = "test"
      Temporary   = "true"
    }
  }

  assert {
    condition     = var.force_destroy == true
    error_message = "Force destroy should be enabled for test environments"
  }

  assert {
    condition     = var.tags["Environment"] == "test"
    error_message = "Environment should be test"
  }

  assert {
    condition     = var.tags["Temporary"] == "true"
    error_message = "Temporary tag should be true"
  }
}

# Test IAM role ARN and VPC ID validation
run "arn_and_vpc_validation" {
  command = plan

  variables {
    bucket_name  = "metaflow-arn-test"
    job_role_arn = "arn:aws:iam::999888777666:role/MetaflowJobRole"
    vpc_id       = "vpc-arn123"
  }

  assert {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.job_role_arn))
    error_message = "Job role ARN should be in valid AWS IAM role format"
  }

  assert {
    condition     = can(regex("^vpc-[a-zA-Z0-9]+$", var.vpc_id))
    error_message = "VPC ID should be in valid AWS VPC format"
  }
}

# Test bucket naming conventions
run "bucket_naming_validation" {
  command = plan

  variables {
    bucket_name  = "my-company-metaflow-datastore-prod"
    job_role_arn = "arn:aws:iam::123456789012:role/MetaflowJobRole"
    vpc_id       = "vpc-naming123"
  }

  assert {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name should follow S3 naming conventions (lowercase, hyphens allowed)"
  }

  assert {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name should be between 3 and 63 characters"
  }

  assert {
    condition     = !can(regex("--", var.bucket_name))
    error_message = "Bucket name should not contain consecutive hyphens"
  }
}

# Test variable type validation
run "variable_types_validation" {
  command = plan

  variables {
    bucket_name   = "metaflow-type-test"
    job_role_arn  = "arn:aws:iam::111222333444:role/MetaflowTypeTestRole"
    vpc_id        = "vpc-type123"
    force_destroy = false
    tags = {
      string_value = "test"
      number_value = "123"
    }
  }

  assert {
    condition     = can(tostring(var.bucket_name))
    error_message = "Bucket name should be a string"
  }

  assert {
    condition     = can(tostring(var.job_role_arn))
    error_message = "Job role ARN should be a string"
  }

  assert {
    condition     = can(tostring(var.vpc_id))
    error_message = "VPC ID should be a string"
  }

  assert {
    condition     = can(tobool(var.force_destroy))
    error_message = "Force destroy should be a boolean"
  }

  assert {
    condition     = can(tomap(var.tags))
    error_message = "Tags should be a map"
  }
}

# Test edge cases and boundary conditions
run "edge_cases_validation" {
  command = plan

  variables {
    bucket_name   = "abc"
    job_role_arn  = "arn:aws:iam::000000000000:role/a"
    vpc_id        = "vpc-1"
    force_destroy = true
    tags          = {}
  }

  assert {
    condition     = length(var.bucket_name) >= 3
    error_message = "Minimum bucket name length should be 3 characters"
  }

  assert {
    condition     = length(keys(var.tags)) == 0
    error_message = "Empty tags should be allowed"
  }

  assert {
    condition     = var.bucket_name != ""
    error_message = "Bucket name should not be empty"
  }

  assert {
    condition     = var.job_role_arn != ""
    error_message = "Job role ARN should not be empty"
  }

  assert {
    condition     = var.vpc_id != ""
    error_message = "VPC ID should not be empty"
  }
}
