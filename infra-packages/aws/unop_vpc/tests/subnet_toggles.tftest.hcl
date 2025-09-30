# Toggling subnet creation on/off

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "private_only" {
  command = plan

  variables {
    name_prefix            = "unop-private-only"
    vpc_cidr_block         = "10.30.0.0/16"
    create_private_subnets = true
    create_public_subnets  = false
    gateway_endpoints      = []
    interface_endpoints    = []
  }

  assert {
    condition     = var.create_private_subnets == true && var.create_public_subnets == false
    error_message = "private_only should disable public subnets"
  }
}

run "public_only" {
  command = plan

  variables {
    name_prefix            = "unop-public-only"
    vpc_cidr_block         = "10.40.0.0/16"
    create_private_subnets = false
    create_public_subnets  = true
    gateway_endpoints      = []
    interface_endpoints    = []
  }

  assert {
    condition     = var.create_private_subnets == false && var.create_public_subnets == true
    error_message = "public_only should disable private subnets"
  }
}
