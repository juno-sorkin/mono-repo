# Multi-AZ behavior, subnet CIDR derivation

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "multi_az_private_public" {
  command = plan

  variables {
    name_prefix        = "unop-multi-az"
    vpc_cidr_block     = "10.20.0.0/16"
    availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
    subnet_newbits     = 8
    public_subnet_offset = 64
    interface_endpoints = []
    gateway_endpoints   = []
  }

  assert {
    condition     = length(var.availability_zones) == 3
    error_message = "should accept 3 AZs"
  }

  assert {
    condition     = var.create_private_subnets && var.create_public_subnets
    error_message = "both private and public subnets should be enabled by default"
  }
}
