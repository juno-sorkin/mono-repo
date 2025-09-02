# services/qwen_ft/infra/backend.tf

terraform {
  backend "s3" {
    bucket         = "tf-backend-logen-dev"
    key            = "services/qwen_ft/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "tf-lock-logen-dev"
  }
}
