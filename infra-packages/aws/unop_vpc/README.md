# unop_vpc

Minimal, best-practice VPC wrapper around `terraform-aws-modules/vpc/aws` designed for private networking without NAT. It supports a variable number of private and/or public subnets with sensible CIDR defaults and provisions VPC endpoints (gateway and interface) to enable egress/ingress for services like S3, DynamoDB, and ECR.

## Example
```hcl
module "unop_vpc" {
  source = "./infra-packages/aws/unop_vpc"

  name_prefix        = "platform-prod"
  vpc_cidr_block     = "10.10.0.0/16"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

  create_private_subnets = true
  create_public_subnets  = true

  # endpoints
  gateway_endpoints   = ["s3", "dynamodb"]
  interface_endpoints = ["ecr.api", "ecr.dkr", "logs"]

  tags = {
    Environment = "production"
    Project     = "metaflow"
  }
}
```

Notes:
- NAT Gateways are not created. For outbound to AWS services from private subnets, use interface endpoints where available.
- Public subnets are optional; if disabled, the VPC will be fully private.

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
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.interface_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Single Availability Zone for resources (fallback when availability\_zones is empty). | `string` | `"us-east-2a"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of Availability Zones to spread subnets across. | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for VPC endpoint service names. | `string` | `"us-east-2"` | no |
| <a name="input_create_private_subnets"></a> [create\_private\_subnets](#input\_create\_private\_subnets) | Whether to create private subnets (recommended). | `bool` | `true` | no |
| <a name="input_create_public_subnets"></a> [create\_public\_subnets](#input\_create\_public\_subnets) | Whether to create public subnets (for bastion/ingress). | `bool` | `true` | no |
| <a name="input_enable_internet_gateway"></a> [enable\_internet\_gateway](#input\_enable\_internet\_gateway) | Whether to attach an Internet Gateway (useful if public subnets are created). | `bool` | `true` | no |
| <a name="input_gateway_endpoints"></a> [gateway\_endpoints](#input\_gateway\_endpoints) | Gateway endpoint services to create (e.g., s3, dynamodb). | `list(string)` | <pre>[<br/>  "s3",<br/>  "dynamodb"<br/>]</pre> | no |
| <a name="input_interface_endpoints"></a> [interface\_endpoints](#input\_interface\_endpoints) | Interface endpoint services to create (e.g., ecr.api, ecr.dkr). | `list(string)` | <pre>[<br/>  "ecr.api",<br/>  "ecr.dkr"<br/>]</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming all resources (e.g., platform-prod). | `string` | n/a | yes |
| <a name="input_public_subnet_offset"></a> [public\_subnet\_offset](#input\_public\_subnet\_offset) | Index offset applied to public subnet CIDR calculation to avoid overlap with private subnets. | `number` | `64` | no |
| <a name="input_subnet_newbits"></a> [subnet\_newbits](#input\_subnet\_newbits) | New bits when deriving subnet CIDRs from VPC CIDR (e.g., 8 -> /24 subnets from /16 VPC). | `number` | `8` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | IPv4 CIDR block for the VPC (e.g., 10.10.0.0/16). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the default security group for the VPC. |
| <a name="output_gateway_vpc_endpoints"></a> [gateway\_vpc\_endpoints](#output\_gateway\_vpc\_endpoints) | Gateway VPC endpoints created (by service). |
| <a name="output_interface_endpoints_security_group_id"></a> [interface\_endpoints\_security\_group\_id](#output\_interface\_endpoints\_security\_group\_id) | Security group ID used for interface endpoints. |
| <a name="output_interface_vpc_endpoints"></a> [interface\_vpc\_endpoints](#output\_interface\_vpc\_endpoints) | Interface VPC endpoints created (by service). |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | Route table IDs associated with private subnets. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | IDs of created private subnets. |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | Route table IDs associated with public subnets. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | IDs of created public subnets. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The primary CIDR block of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the created VPC. |
<!-- END_TF_DOCS -->
