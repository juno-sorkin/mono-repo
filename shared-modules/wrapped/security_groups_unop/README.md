# Terraform Module: security_groups_unop

## Overview

This module provides a standardized, consistent interface for creating security groups that will be consumed by other application-specific modules (e.g., for RDS, Batch, EFS). It is a thin wrapper around the public `terraform-aws-modules/security-group/aws` module, designed to enforce project-level conventions and simplify inter-module dependencies.

## Example Usage

```hcl
module "rds_sg" {
  source = "./shared-modules/wrapped/security_groups_unop"

  project_prefix = "metaflow-prod"
  context_name   = "rds-postgres"
  vpc_id         = "vpc-12345678"
  common_tags    = {
    Environment = "Production"
    Project     = "Metaflow"
  }

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow Postgres traffic from Metaflow Batch jobs"
      source_security_group_id = "sg-abcdef12"
    }
  ]
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
| <a name="module_security-group"></a> [security-group](#module\_security-group) | terraform-aws-modules/security-group/aws | 5.3.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Optional: Merged with common\_tags to allow resource-specific tagging. | `map(string)` | `{}` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | A map of tags to be applied to all security groups created by this module. | `map(string)` | `{}` | no |
| <a name="input_context_name"></a> [context\_name](#input\_context\_name) | The name of the resource or component this SG is for (e.g., 'rds', 'batch'). | `string` | n/a | yes |
| <a name="input_egress_with_cidr_blocks"></a> [egress\_with\_cidr\_blocks](#input\_egress\_with\_cidr\_blocks) | Allows egress to the internet ('0.0.0.0/0') or specific VPC endpoints. | `list(any)` | `[]` | no |
| <a name="input_egress_with_source_security_group_id"></a> [egress\_with\_source\_security\_group\_id](#input\_egress\_with\_source\_security\_group\_id) | Less common, but allows for specific egress paths to other security groups. | `list(any)` | `[]` | no |
| <a name="input_ingress_with_cidr_blocks"></a> [ingress\_with\_cidr\_blocks](#input\_ingress\_with\_cidr\_blocks) | Allows ingress from specific network ranges (e.g., a bastion host or corporate VPN). | `list(any)` | `[]` | no |
| <a name="input_ingress_with_source_security_group_id"></a> [ingress\_with\_source\_security\_group\_id](#input\_ingress\_with\_source\_security\_group\_id) | The primary mechanism for allowing ingress from other resources (e.g., Batch SG -> RDS SG). | `list(any)` | `[]` | no |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | A prefix for all resources to ensure uniqueness (e.g., 'metaflow-prod'). | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Required: The ID of the VPC where the security group will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the security group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the security group, used for rule definitions. |
| <a name="output_name"></a> [name](#output\_name) | The computed name of the security group. |
<!-- END_TF_DOCS -->
