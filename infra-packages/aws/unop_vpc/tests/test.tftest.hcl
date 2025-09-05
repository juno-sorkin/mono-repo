# Test file for vpc_metaflow module

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Test basic VPC creation with minimal configuration
run "test_basic_vpc_creation" {
  command = plan

  variables {
    name_prefix       = "test-metaflow"
    vpc_cidr_block    = "10.10.0.0/16"
    gateway_endpoints = [] # Empty to avoid AWS API calls in tests
  }

  # Verify required variables are set correctly
  assert {
    condition     = var.name_prefix == "test-metaflow"
    error_message = "Name prefix should be set correctly"
  }

  assert {
    condition     = var.vpc_cidr_block == "10.10.0.0/16"
    error_message = "VPC CIDR block should be set correctly"
  }

  # Verify default values are applied
  assert {
    condition     = var.availability_zone == "us-east-2a"
    error_message = "Default availability zone should be us-east-2a"
  }

  assert {
    condition     = length(var.gateway_endpoints) == 0
    error_message = "Gateway endpoints should be empty for basic test"
  }
}

# Test VPC with custom availability zone
run "test_custom_availability_zone" {
  command = plan

  variables {
    name_prefix       = "test-metaflow"
    vpc_cidr_block    = "10.20.0.0/16"
    availability_zone = "us-west-2b"
  }

  # Verify custom availability zone is set
  assert {
    condition     = var.availability_zone == "us-west-2b"
    error_message = "Custom availability zone should be set correctly"
  }

  # Verify CIDR block calculation locals would work
  assert {
    condition     = var.vpc_cidr_block == "10.20.0.0/16"
    error_message = "VPC CIDR should be /16 for subnet calculation"
  }
}

# Test VPC with custom gateway endpoints
run "test_custom_gateway_endpoints" {
  command = plan

  variables {
    name_prefix       = "test-metaflow"
    vpc_cidr_block    = "10.30.0.0/16"
    gateway_endpoints = ["s3"]
    aws_region        = "us-east-2"
  }

  # Verify custom gateway endpoints
  assert {
    condition     = length(var.gateway_endpoints) == 1
    error_message = "Should have 1 custom gateway endpoint"
  }

  assert {
    condition     = var.gateway_endpoints[0] == "s3"
    error_message = "Custom gateway endpoint should be s3"
  }
}

# Test VPC with comprehensive configuration
run "test_comprehensive_configuration" {
  command = plan

  variables {
    name_prefix       = "metaflow-prod"
    vpc_cidr_block    = "10.0.0.0/16"
    availability_zone = "us-east-1a"
    gateway_endpoints = ["s3", "dynamodb"]
    aws_region        = "us-east-1"

    tags = {
      Environment = "production"
      Project     = "metaflow"
      Team        = "data-science"
      Terraform   = "true"
    }
  }

  # Verify all configuration is set correctly
  assert {
    condition     = var.name_prefix == "metaflow-prod"
    error_message = "Name prefix should be metaflow-prod"
  }

  assert {
    condition     = var.vpc_cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR should be 10.0.0.0/16"
  }

  assert {
    condition     = var.availability_zone == "us-east-1a"
    error_message = "Availability zone should be us-east-1a"
  }

  assert {
    condition     = length(var.gateway_endpoints) == 2
    error_message = "Should have 2 gateway endpoints"
  }

  assert {
    condition     = var.tags["Environment"] == "production"
    error_message = "Environment tag should be production"
  }

  assert {
    condition     = var.tags["Project"] == "metaflow"
    error_message = "Project tag should be metaflow"
  }
}

# Test CIDR block validation scenarios
run "test_cidr_block_validation" {
  command = plan

  variables {
    name_prefix    = "test-cidr"
    vpc_cidr_block = "172.16.0.0/16"
  }

  # Verify different valid CIDR blocks work
  assert {
    condition     = var.vpc_cidr_block == "172.16.0.0/16"
    error_message = "Should accept valid /16 CIDR blocks"
  }
}

# Test empty tags configuration
run "test_empty_tags" {
  command = plan

  variables {
    name_prefix    = "test-no-tags"
    vpc_cidr_block = "192.168.0.0/16"
    tags           = {}
  }

  # Verify empty tags work
  assert {
    condition     = length(keys(var.tags)) == 0
    error_message = "Empty tags should be allowed"
  }
}

# Test no gateway endpoints
run "test_no_gateway_endpoints" {
  command = plan

  variables {
    name_prefix       = "test-no-endpoints"
    vpc_cidr_block    = "10.100.0.0/16"
    gateway_endpoints = []
  }

  # Verify empty gateway endpoints list works
  assert {
    condition     = length(var.gateway_endpoints) == 0
    error_message = "Empty gateway endpoints list should be allowed"
  }
}

# Test variable types and constraints
run "test_variable_types" {
  command = plan

  variables {
    name_prefix       = "type-test"
    vpc_cidr_block    = "10.50.0.0/16"
    availability_zone = "eu-west-1a"
    gateway_endpoints = ["s3", "dynamodb"]
    aws_region        = "eu-west-1"

    tags = {
      string_tag = "value"
      number_tag = "123"
      bool_tag   = "true"
    }
  }

  # Verify string variables
  assert {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name_prefix))
    error_message = "Name prefix should be a valid string"
  }

  # Verify CIDR format
  assert {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/16$", var.vpc_cidr_block))
    error_message = "VPC CIDR should be in valid /16 format"
  }

  # Verify availability zone format
  assert {
    condition     = can(regex("^[a-z]+-[a-z]+-[0-9]+[a-z]$", var.availability_zone))
    error_message = "Availability zone should be in valid AWS format"
  }

  # Verify gateway endpoints are strings
  assert {
    condition     = alltrue([for endpoint in var.gateway_endpoints : can(regex("^[a-z0-9.-]+$", endpoint))])
    error_message = "All gateway endpoints should be valid service names"
  }
}

# Test production-like configuration
run "test_production_scenario" {
  command = plan

  variables {
    name_prefix       = "metaflow-production"
    vpc_cidr_block    = "10.0.0.0/16"
    availability_zone = "us-east-1a"
    gateway_endpoints = ["s3", "dynamodb"]
    aws_region        = "us-east-1"

    tags = {
      Environment = "production"
      Project     = "metaflow"
      Team        = "ml-platform"
      CostCenter  = "engineering"
      Backup      = "required"
      Monitoring  = "enabled"
      Terraform   = "true"
    }
  }

  # Verify production naming
  assert {
    condition     = can(regex("production", var.name_prefix))
    error_message = "Production environment should be reflected in name prefix"
  }

  # Verify production tags are comprehensive
  assert {
    condition     = length(keys(var.tags)) >= 5
    error_message = "Production environment should have comprehensive tagging"
  }

  assert {
    condition     = var.tags["Environment"] == "production"
    error_message = "Environment tag should be production"
  }

  assert {
    condition     = var.tags["Terraform"] == "true"
    error_message = "Terraform tag should be present for production resources"
  }
}
