# Variable validation shapes and formats

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "naming_and_formats" {
  command = plan

  variables {
    name_prefix         = "unop-prod-1"
    vpc_cidr_block      = "172.16.0.0/16"
    availability_zone   = "us-east-2a"
    availability_zones  = []
    gateway_endpoints   = ["s3", "dynamodb"]
    interface_endpoints = []
  }

  assert {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name_prefix))
    error_message = "name_prefix should be alphanumeric with dashes"
  }

  assert {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/16$", var.vpc_cidr_block))
    error_message = "vpc_cidr_block should be /16 CIDR for defaults"
  }

  assert {
    condition     = can(regex("^[a-z]+-[a-z]+-[0-9]+[a-z]$", var.availability_zone))
    error_message = "availability_zone should match AWS format (e.g., us-east-2a)"
  }

  assert {
    condition     = alltrue([for e in var.gateway_endpoints : can(regex("^[a-z0-9.-]+$", e))])
    error_message = "gateway_endpoints values should be valid service names"
  }
}
