# Terraform Module: iam_metaflow

## Overview

This module provides a comprehensive IAM foundation for Metaflow on AWS Batch deployments. It creates all the necessary IAM roles and policies required for a secure and functional Metaflow environment, including roles for Batch jobs, Batch service operations, EC2 instances, and optional Spot Fleet management.

## Features

- **Batch Job Role** - Grants Metaflow tasks access to S3, ECR, and CloudWatch
- **Batch Service Role** - Allows AWS Batch to manage compute environments
- **EC2 Instance Role & Profile** - Enables EC2 instances to join Batch compute environments
- **Optional Spot Fleet Role** - Supports cost-effective Spot instance usage
- **Seamless Integration** - Outputs designed to work with other wrapper modules
- **Extensible Permissions** - Support for additional managed policies and custom inline policies

## Integration with Other Modules

This module is designed to integrate seamlessly with other Metaflow wrapper modules:

- **s3_metaflow**: Use `batch_job_role_arn` for the `job_role_arn` variable
- **ecr_unop**: Use `batch_job_role_arn` for the `job_role_arn` variable
- **AWS Batch module**: Use the service role and instance role ARNs for compute environments

## Example Usage

### Basic Metaflow IAM Setup

```hcl
module "metaflow_iam" {
  source = "./shared-modules/wrapped/iam_metaflow"

  name_prefix = "metaflow-prod"

  tags = {
    Environment = "production"
    Project     = "metaflow"
  }
}

# Use with other modules
module "metaflow_s3" {
  source = "./shared-modules/wrapped/s3_metaflow"

  bucket_name  = "metaflow-prod-datastore"
  job_role_arn = module.metaflow_iam.batch_job_role_arn

  tags = {
    Environment = "production"
  }
}
```

### Advanced Setup with Custom Policies

```hcl
module "metaflow_iam" {
  source = "./shared-modules/wrapped/iam_metaflow"

  name_prefix = "metaflow-prod"
  enable_spot_fleet_role = true

  # Additional managed policies for job role
  additional_job_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
  ]

  # Custom inline policy for specific requirements
  custom_job_policy_statements = {
    secrets_access = {
      sid    = "AllowSecretsManagerAccess"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [
        "arn:aws:secretsmanager:*:*:secret:metaflow/*"
      ]
    }
  }

  tags = {
    Environment = "production"
    Project     = "metaflow"
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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_batch_instance_role"></a> [batch\_instance\_role](#module\_batch\_instance\_role) | terraform-aws-modules/iam/aws//modules/iam-role | ~> 6.1 |
| <a name="module_batch_job_role"></a> [batch\_job\_role](#module\_batch\_job\_role) | terraform-aws-modules/iam/aws//modules/iam-role | ~> 6.1 |
| <a name="module_batch_service_role"></a> [batch\_service\_role](#module\_batch\_service\_role) | terraform-aws-modules/iam/aws//modules/iam-role | ~> 6.1 |
| <a name="module_spot_fleet_role"></a> [spot\_fleet\_role](#module\_spot\_fleet\_role) | terraform-aws-modules/iam/aws//modules/iam-role | 6.2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_job_policy_arns"></a> [additional\_job\_policy\_arns](#input\_additional\_job\_policy\_arns) | Additional managed policy ARNs to attach to the Batch job role beyond the default CloudWatch, S3, and ECR policies | `list(string)` | `[]` | no |
| <a name="input_custom_job_policy_statements"></a> [custom\_job\_policy\_statements](#input\_custom\_job\_policy\_statements) | Optional custom inline policy statements for the Batch job role. Use this for specific permissions not covered by managed policies. | <pre>map(object({<br>    sid           = optional(string)<br>    actions       = optional(list(string))<br>    not_actions   = optional(list(string))<br>    effect        = optional(string, "Allow")<br>    resources     = optional(list(string))<br>    not_resources = optional(list(string))<br>    principals = optional(list(object({<br>      type        = string<br>      identifiers = list(string)<br>    })))<br>    not_principals = optional(list(object({<br>      type        = string<br>      identifiers = list(string)<br>    })))<br>    condition = optional(list(object({<br>      test     = string<br>      variable = string<br>      values   = list(string)<br>    })))<br>  }))</pre> | `null` | no |
| <a name="input_enable_spot_fleet_role"></a> [enable\_spot\_fleet\_role](#input\_enable\_spot\_fleet\_role) | Whether to create a Spot Fleet role for Batch compute environments using Spot instances | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix used for naming all IAM resources (e.g., 'metaflow-prod', 'metaflow-dev') | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all IAM resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_batch_instance_profile_arn"></a> [batch\_instance\_profile\_arn](#output\_batch\_instance\_profile\_arn) | The ARN of the EC2 instance profile. Use this for EC2 instances in Batch compute environments. |
| <a name="output_batch_instance_profile_name"></a> [batch\_instance\_profile\_name](#output\_batch\_instance\_profile\_name) | The name of the EC2 instance profile. |
| <a name="output_batch_instance_role_arn"></a> [batch\_instance\_role\_arn](#output\_batch\_instance\_role\_arn) | The ARN of the EC2 instance role. Use this for the instance\_role variable in AWS Batch compute environments. |
| <a name="output_batch_instance_role_name"></a> [batch\_instance\_role\_name](#output\_batch\_instance\_role\_name) | The name of the EC2 instance role. |
| <a name="output_batch_job_role_arn"></a> [batch\_job\_role\_arn](#output\_batch\_job\_role\_arn) | The ARN of the Batch job role. Use this for the job\_role\_arn variable in s3\_metaflow and ecr\_unop modules. |
| <a name="output_batch_job_role_name"></a> [batch\_job\_role\_name](#output\_batch\_job\_role\_name) | The name of the Batch job role. |
| <a name="output_batch_service_role_arn"></a> [batch\_service\_role\_arn](#output\_batch\_service\_role\_arn) | The ARN of the Batch service role. Use this for the service\_role variable in AWS Batch compute environments. |
| <a name="output_batch_service_role_name"></a> [batch\_service\_role\_name](#output\_batch\_service\_role\_name) | The name of the Batch service role. |
| <a name="output_spot_fleet_role_arn"></a> [spot\_fleet\_role\_arn](#output\_spot\_fleet\_role\_arn) | The ARN of the Spot Fleet role. Only available if enable\_spot\_fleet\_role is true. |
| <a name="output_spot_fleet_role_name"></a> [spot\_fleet\_role\_name](#output\_spot\_fleet\_role\_name) | The name of the Spot Fleet role. Only available if enable\_spot\_fleet\_role is true. |
<!-- END_TF_DOCS -->
