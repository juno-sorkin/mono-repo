# Terraform Module: metaflow-datastore

## Overview

This module provisions an opinionated S3 bucket specifically configured to serve as a datastore for a Metaflow on AWS Batch deployment. It is a wrapper around the official `terraform-aws-modules/s3-bucket/aws` module that encapsulates the specific versioning, encryption, and access control settings required for a secure and functional Metaflow artifact repository.

Its primary design goal is to provide a simple, secure, and network-aware S3 bucket for Metaflow, with minimal configuration required from the end-user.

## Example Usage

```hcl
module "metaflow_datastore" {
  source = "./shared-modules/wrapped/s3_metaflow"

  bucket_name  = "my-metaflow-datastore"
  job_role_arn = "arn:aws:iam::123456789012:role/MetaflowJobRole"

  tags = {
    Environment = "Production"
    Project     = "Metaflow"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 5.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.metaflow_datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The desired name for the S3 bucket. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed. | `bool` | `false` | no |
| <a name="input_job_role_arn"></a> [job\_role\_arn](#input\_job\_role\_arn) | The ARN of the IAM role used by Metaflow jobs, which needs access to this bucket. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the S3 bucket resource. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the Metaflow jobs will run. This is used to restrict S3 access. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name (id) of the S3 bucket. |
<!-- END_TF_DOCS -->
