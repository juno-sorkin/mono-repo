# Terraform Module: vpc_metaflow

## Overview

This module provisions an opinionated VPC network foundation specifically tailored for a Metaflow on AWS Batch deployment. It is a wrapper around the official `terraform-aws-modules/vpc/aws` module that encapsulates the specific topology and service endpoints required for a secure, cost-effective, and functional Metaflow environment operating without a NAT Gateway.

Its primary design goals are simplicity for the end-user and adherence to Metaflow's operational requirements in a private network setting. It is designed to be deployed in a single Availability Zone.



## Example Usage

```hcl
module "vpc_metaflow" {
  source = "./shared-modules/wrapped/vpc_metaflow"

  name_prefix       = "metaflow-prod"
  vpc_cidr_block    = "10.10.0.0/16"
  availability_zone = "us-east-2a"
  gateway_endpoints = ["s3", "dynamodb"]

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.10.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_endpoint.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The single AWS Availability Zone into which all network resources will be deployed (e.g., us-east-2a). | `string` | `"us-east-2a"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for VPC endpoint service names. | `string` | `"us-east-2"` | no |
| <a name="input_gateway_endpoints"></a> [gateway\_endpoints](#input\_gateway\_endpoints) | A list of gateway endpoint services to create (e.g., s3, dynamodb). | `list(string)` | <pre>[<br>  "s3",<br>  "dynamodb"<br>]</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A mandatory prefix used for naming all resources created within the module (e.g., metaflow-prod, data-science-dev). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of AWS tags to apply to all provisioned resources for cost allocation, automation, and identification. | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The IPv4 CIDR block for the VPC. Must be a /16 block (e.g., 10.10.0.0/16) to allow for predictable subnet calculation. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the default security group for the VPC. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | The ID of the single private subnet. The metaflow-runtime and metaflow-metadata modules will deploy their resources here. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | The ID of the single public subnet. Provided for optional resources like a bastion host or public-facing load balancer. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The primary CIDR block of the VPC. Useful for authoring security group rules in other modules. |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | A map of gateway endpoints created for the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the created VPC. Used by nearly all other modules. |
<!-- END_TF_DOCS -->
