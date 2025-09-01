# services/qwen_ft/infra/backend.tf

terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket" # FIXME: Replace with your S3 bucket name
    key            = "services/qwen_ft/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "your-terraform-lock-table" # FIXME: Replace with your DynamoDB table name
  }
}
