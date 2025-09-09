# Basic defaults and required inputs

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "basic_defaults" {
  command = plan

  variables {
    name_prefix    = "unop-basic"
    vpc_cidr_block = "10.0.0.0/16"
  }

  assert {
    condition     = var.name_prefix == "unop-basic"
    error_message = "name_prefix should be set"
  }

  assert {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block))
    error_message = "vpc_cidr_block should be a valid CIDR"
  }

  # Defaults
  assert {
    condition     = var.create_private_subnets == true
    error_message = "create_private_subnets default should be true"
  }

  assert {
    condition     = var.create_public_subnets == true
    error_message = "create_public_subnets default should be true"
  }

  assert {
    condition     = var.enable_internet_gateway == true
    error_message = "enable_internet_gateway default should be true"
  }

  # Endpoint defaults
  assert {
    condition     = contains(var.gateway_endpoints, "s3") && contains(var.gateway_endpoints, "dynamodb")
    error_message = "gateway_endpoints should default to s3 and dynamodb"
  }

  assert {
    condition     = contains(var.interface_endpoints, "ecr.api") && contains(var.interface_endpoints, "ecr.dkr")
    error_message = "interface_endpoints should default to ecr.api and ecr.dkr"
  }
}
