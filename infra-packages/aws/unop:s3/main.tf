# infra-packages/aws/s3_metaflow/main.tf

# Data source to create the network-aware bucket policy
data "aws_iam_policy_document" "metaflow_datastore" {
  # Allow the Metaflow job role to access the bucket
  statement {
    sid    = "AllowMetaflowJobRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.job_role_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]

    # This is the critical "gotcha" logic
    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpc"
      values   = [var.vpc_id]
    }
  }
}

# Instantiate the public S3 bucket module
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.4.0"

  # Exposed Variables
  bucket        = var.bucket_name
  tags          = var.tags
  force_destroy = var.force_destroy

  # Hardcoded Variables for Metaflow
  versioning = {
    status = "Enabled"
  }
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Attach our dynamically generated policy
  attach_policy = true
  policy        = data.aws_iam_policy_document.metaflow_datastore.json
}
