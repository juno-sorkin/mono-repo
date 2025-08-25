# Terraform Module: ecr_unop

## Overview

This module provides a standardized, opinionated wrapper for provisioning Amazon ECR repositories. It enforces sensible defaults including immutable tags, automatic lifecycle policies for untagged images, and optional IAM role-based access control. The module is designed specifically for Metaflow MLOps infrastructure.

## Features

- **Immutable tags by default** - Prevents accidental image overwriting
- **Automatic lifecycle policy** - Removes untagged images older than 14 days
- **Optional IAM integration** - Grants read/write access to specified job roles
- **Force delete support** - Configurable repository deletion even with images
- **Standardized tagging** - Consistent resource management and identification

## Example Usage

```hcl
module "metaflow_ecr" {
  source = "./shared-modules/wrapped/ecr_unop"

  repository_name = "metaflow-flows"
  job_role_arn    = "arn:aws:iam::123456789012:role/MetaflowBatchJobRole"
  force_delete    = true

  tags = {
    "usage"       = "metaflow-runtime"
    "environment" = "production"
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
| <a name="module_ecr"></a> [ecr](#module\_ecr) | terraform-aws-modules/ecr/aws | 3.0.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | If `true`, will delete the repository even if it contains images. Defaults to `false` | `bool` | `false` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. Defaults to `IMMUTABLE` | `string` | `"IMMUTABLE"` | no |
| <a name="input_job_role_arn"></a> [job\_role\_arn](#input\_job\_role\_arn) | The ARN of the IAM role that will be granted read/write access to the ECR repository. If null, no repository policy will be attached. | `string` | `null` | no |
| <a name="input_lifecycle_policy_json"></a> [lifecycle\_policy\_json](#input\_lifecycle\_policy\_json) | The policy document. This is a JSON formatted string. See more details about [Policy Parameters](http://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters) in the official AWS docs. If null, a default policy will be applied. | `string` | `null` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | The name of the repository | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | The ARN of the repository, used for IAM policies. |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | The name of the repository. |
| <a name="output_repository_registry_id"></a> [repository\_registry\_id](#output\_repository\_registry\_id) | The AWS account ID (registry ID) where the repository lives. |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | The URL of the repository, used by Docker clients and CI/CD systems. |
<!-- END_TF_DOCS -->
