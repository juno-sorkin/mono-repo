# Endpoint combinations: gateway and interface

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "no_endpoints" {
  command = plan

  variables {
    name_prefix         = "unop-no-ep"
    vpc_cidr_block      = "10.50.0.0/16"
    gateway_endpoints   = []
    interface_endpoints = []
  }

  assert {
    condition     = length(var.gateway_endpoints) == 0 && length(var.interface_endpoints) == 0
    error_message = "should allow no endpoints"
  }
}

run "ecr_only" {
  command = plan

  variables {
    name_prefix         = "unop-ecr-ep"
    vpc_cidr_block      = "10.60.0.0/16"
    gateway_endpoints   = []
    interface_endpoints = ["ecr.api", "ecr.dkr"]
  }

  assert {
    condition     = alltrue([for s in var.interface_endpoints : contains(["ecr.api", "ecr.dkr"], s)])
    error_message = "interface endpoints should include ecr.api and ecr.dkr"
  }
}

run "s3_dynamodb_only" {
  command = plan

  variables {
    name_prefix         = "unop-gw-ep"
    vpc_cidr_block      = "10.70.0.0/16"
    gateway_endpoints   = ["s3", "dynamodb"]
    interface_endpoints = []
  }

  assert {
    condition     = alltrue([for s in var.gateway_endpoints : contains(["s3", "dynamodb"], s)])
    error_message = "gateway endpoints should include s3 and dynamodb"
  }
}
