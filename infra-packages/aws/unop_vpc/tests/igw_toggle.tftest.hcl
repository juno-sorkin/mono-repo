# Internet Gateway toggle

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

run "igw_disabled" {
  command = plan

  variables {
    name_prefix            = "unop-no-igw"
    vpc_cidr_block         = "10.80.0.0/16"
    enable_internet_gateway = false
    interface_endpoints     = []
    gateway_endpoints       = []
  }

  assert {
    condition     = var.enable_internet_gateway == false
    error_message = "enable_internet_gateway should be false when toggled off"
  }
}
