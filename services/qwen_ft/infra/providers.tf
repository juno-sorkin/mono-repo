# services/qwen_ft/infra/providers.tf

provider "aws" {
  profile = "terraform-keys"
  region  = "us-east-2"
}
