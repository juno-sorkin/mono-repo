# Terraform Module: batch_metaflow

## Overview

This module provisions an opinionated AWS Batch infrastructure specifically tailored for Metaflow on AWS deployments. It creates compute environments, job queues, and job definitions optimized for cost-effective, on-demand execution of data science and machine learning workflows.

The module is designed around Metaflow's core principle of minimizing idle costs by using compute environments with **minimum vCPU count of zero**, ensuring no EC2 instances run when no jobs are executing.

## Key Features

- **Cost-Optimized Design**: Compute environments start with 0 vCPUs and scale on-demand
- **Multi-Tier Compute**: On-Demand, Spot, and optional GPU compute environments
- **Smart Job Queues**: Prioritizes cost-effective Spot instances with On-Demand fallback
- **Metaflow Integration**: Pre-configured job definitions with proper IAM roles and logging
- **Seamless Integration**: Designed to work with vpc_metaflow and iam_metaflow modules

## Architecture

### Compute Environments
1. **On-Demand**: Reliable compute for critical workloads
2. **Spot** (optional): Cost-effective compute with up to 90% savings
3. **GPU** (optional): Specialized compute for ML training and inference

### Job Queues
- **Default Queue**: Routes jobs to Spot first, falls back to On-Demand
- **GPU Queue**: Dedicated queue for GPU-intensive workloads

### Job Definitions
- **Default Definition**: Pre-configured for Metaflow with proper logging and IAM roles

## Integration with Other Modules

This module integrates seamlessly with other Metaflow wrapper modules:

- **vpc_metaflow**: Provides VPC ID and subnet IDs
- **iam_metaflow**: Provides all required IAM role ARNs
- **security_groups_unop**: Provides security group IDs

## Example Usage

### Basic Metaflow Batch Setup

```hcl
module "metaflow_batch" {
  source = "./shared-modules/wrapped/batch_metaflow"

  name_prefix = "metaflow-prod"

  # From vpc_metaflow module
  subnet_ids = module.vpc_metaflow.public_subnets

  # From security groups
  security_group_ids = [module.security_groups.batch_security_group_id]

  # From iam_metaflow module
  job_role_arn          = module.iam_metaflow.batch_job_role_arn
  instance_profile_arn  = module.iam_metaflow.batch_instance_profile_arn
  service_role_arn      = module.iam_metaflow.batch_service_role_arn

  tags = {
    Environment = "production"
    Project     = "metaflow"
  }
}
```

### Advanced Setup with GPU and Spot Instances

```hcl
module "metaflow_batch" {
  source = "./shared-modules/wrapped/batch_metaflow"

  name_prefix = "metaflow-prod"

  # Networking and security
  subnet_ids         = module.vpc_metaflow.public_subnets
  security_group_ids = [module.security_groups.batch_security_group_id]

  # IAM roles
  job_role_arn          = module.iam_metaflow.batch_job_role_arn
  instance_profile_arn  = module.iam_metaflow.batch_instance_profile_arn
  service_role_arn      = module.iam_metaflow.batch_service_role_arn
  spot_fleet_role_arn   = module.iam_metaflow.spot_fleet_role_arn

  # Compute configuration
  max_vcpus                       = 32
  instance_types                  = ["m5.large", "m5.xlarge", "c5.xlarge"]
  enable_spot_compute_environment = true
  spot_bid_percentage             = 60

  # GPU configuration for ML workloads
  enable_gpu_compute_environment = true
  gpu_instance_types             = ["g4dn.xlarge", "g4dn.2xlarge"]
  gpu_max_vcpus                  = 64

  # Custom container image
  default_container_image = "public.ecr.aws/lambda/python:3.9"

  tags = {
    Environment = "production"
    Project     = "metaflow"
    CostCenter  = "data-science"
  }
}
```

### Using with Metaflow Configuration

After deploying this module, configure Metaflow to use the created resources:

```python
# In your Metaflow configuration
METAFLOW_BATCH_JOB_QUEUE = module.metaflow_batch.metaflow_batch_job_queue
METAFLOW_BATCH_JOB_DEFINITION = module.metaflow_batch.metaflow_batch_job_definition
```

## Cost Optimization

This module implements several cost optimization strategies:

1. **Zero Idle Costs**: All compute environments start with 0 desired vCPUs
2. **Spot Instance Priority**: Default job queue prioritizes Spot instances
3. **Right-Sized Defaults**: Conservative instance types and vCPU limits
4. **On-Demand Scaling**: Resources scale up only when jobs are submitted

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_batch"></a> [batch](#module\_batch) | terraform-aws-modules/batch/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_container_image"></a> [default\_container\_image](#input\_default\_container\_image) | Default container image for Metaflow jobs. Uses AWS Deep Learning Container by default. | `string` | `"public.ecr.aws/lambda/python:3.9"` | no |
| <a name="input_enable_gpu_compute_environment"></a> [enable\_gpu\_compute\_environment](#input\_enable\_gpu\_compute\_environment) | Whether to create a GPU-enabled compute environment for ML workloads. | `bool` | `false` | no |
| <a name="input_enable_spot_compute_environment"></a> [enable\_spot\_compute\_environment](#input\_enable\_spot\_compute\_environment) | Whether to create a Spot compute environment for cost savings. Recommended for non-critical workloads. | `bool` | `true` | no |
| <a name="input_gpu_instance_types"></a> [gpu\_instance\_types](#input\_gpu\_instance\_types) | List of GPU-enabled EC2 instance types for ML workloads. | `list(string)` | <pre>[<br>  "g4dn.xlarge",<br>  "g4dn.2xlarge",<br>  "p3.2xlarge"<br>]</pre> | no |
| <a name="input_gpu_max_vcpus"></a> [gpu\_max\_vcpus](#input\_gpu\_max\_vcpus) | Maximum number of vCPUs for the GPU compute environment. | `number` | `32` | no |
| <a name="input_instance_profile_arn"></a> [instance\_profile\_arn](#input\_instance\_profile\_arn) | ARN of the EC2 instance profile for Batch compute environments. Use batch\_instance\_profile\_arn from iam\_metaflow module. | `string` | n/a | yes |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | List of EC2 instance types for Batch compute environments. Optimized for general-purpose workloads. | `list(string)` | <pre>[<br>  "m5.large",<br>  "m5.xlarge",<br>  "c5.large",<br>  "c5.xlarge"<br>]</pre> | no |
| <a name="input_job_role_arn"></a> [job\_role\_arn](#input\_job\_role\_arn) | ARN of the IAM role for Batch jobs. Use batch\_job\_role\_arn from iam\_metaflow module. | `string` | n/a | yes |
| <a name="input_max_vcpus"></a> [max\_vcpus](#input\_max\_vcpus) | Maximum number of vCPUs for the compute environment. Controls the maximum scale of your Batch jobs. | `number` | `16` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A mandatory prefix used for naming all Batch resources (e.g., metaflow-prod, data-science-dev). | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to Batch compute environments. | `list(string)` | n/a | yes |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | ARN of the Batch service role. Use batch\_service\_role\_arn from iam\_metaflow module. | `string` | n/a | yes |
| <a name="input_spot_bid_percentage"></a> [spot\_bid\_percentage](#input\_spot\_bid\_percentage) | The maximum percentage of On-Demand pricing to pay for Spot instances (1-100). | `number` | `50` | no |
| <a name="input_spot_fleet_role_arn"></a> [spot\_fleet\_role\_arn](#input\_spot\_fleet\_role\_arn) | ARN of the Spot Fleet role for Spot instances. Use spot\_fleet\_role\_arn from iam\_metaflow module if using Spot instances. | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for Batch compute environments. Use public subnets from vpc\_metaflow module. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of AWS tags to apply to all Batch resources for cost allocation and identification. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_environments"></a> [compute\_environments](#output\_compute\_environments) | Map of all compute environments created and their attributes. |
| <a name="output_default_job_definition_arn"></a> [default\_job\_definition\_arn](#output\_default\_job\_definition\_arn) | ARN of the default job definition. |
| <a name="output_default_job_definition_name"></a> [default\_job\_definition\_name](#output\_default\_job\_definition\_name) | Name of the default job definition. |
| <a name="output_default_job_queue_arn"></a> [default\_job\_queue\_arn](#output\_default\_job\_queue\_arn) | ARN of the default job queue. Use this for Metaflow configuration. |
| <a name="output_default_job_queue_name"></a> [default\_job\_queue\_name](#output\_default\_job\_queue\_name) | Name of the default job queue. Use this for Metaflow configuration. |
| <a name="output_gpu_compute_environment_arn"></a> [gpu\_compute\_environment\_arn](#output\_gpu\_compute\_environment\_arn) | ARN of the GPU compute environment. Only available if enable\_gpu\_compute\_environment is true. |
| <a name="output_gpu_job_queue_arn"></a> [gpu\_job\_queue\_arn](#output\_gpu\_job\_queue\_arn) | ARN of the GPU job queue. Only available if enable\_gpu\_compute\_environment is true. |
| <a name="output_gpu_job_queue_name"></a> [gpu\_job\_queue\_name](#output\_gpu\_job\_queue\_name) | Name of the GPU job queue. Only available if enable\_gpu\_compute\_environment is true. |
| <a name="output_job_definitions"></a> [job\_definitions](#output\_job\_definitions) | Map of all job definitions created and their attributes. |
| <a name="output_job_queues"></a> [job\_queues](#output\_job\_queues) | Map of all job queues created and their attributes. |
| <a name="output_metaflow_batch_job_definition"></a> [metaflow\_batch\_job\_definition](#output\_metaflow\_batch\_job\_definition) | The job definition ARN to use in Metaflow configuration. |
| <a name="output_metaflow_batch_job_queue"></a> [metaflow\_batch\_job\_queue](#output\_metaflow\_batch\_job\_queue) | The job queue name to use in Metaflow configuration. |
| <a name="output_ondemand_compute_environment_arn"></a> [ondemand\_compute\_environment\_arn](#output\_ondemand\_compute\_environment\_arn) | ARN of the On-Demand compute environment. |
| <a name="output_spot_compute_environment_arn"></a> [spot\_compute\_environment\_arn](#output\_spot\_compute\_environment\_arn) | ARN of the Spot compute environment. Only available if enable\_spot\_compute\_environment is true. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.10.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_batch"></a> [batch](#module\_batch) | git::https://github.com/terraform-aws-modules/terraform-aws-batch.git | v3.0.4 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for CloudWatch logs configuration. | `string` | `"us-east-2"` | no |
| <a name="input_default_container_image"></a> [default\_container\_image](#input\_default\_container\_image) | Default container image for Metaflow jobs. Uses AWS Deep Learning Container by default. pull from public docker registry or dlc, not custom ecr | `string` | n/a | yes |
| <a name="input_enable_gpu_compute_environment"></a> [enable\_gpu\_compute\_environment](#input\_enable\_gpu\_compute\_environment) | Whether to create a GPU-enabled compute environment for ML workloads. | `bool` | `false` | no |
| <a name="input_enable_spot_compute_environment"></a> [enable\_spot\_compute\_environment](#input\_enable\_spot\_compute\_environment) | Whether to create a Spot compute environment for cost savings. Recommended for non-critical workloads. | `bool` | `true` | no |
| <a name="input_gpu_instance_types"></a> [gpu\_instance\_types](#input\_gpu\_instance\_types) | List of GPU-enabled EC2 instance types for ML workloads. | `list(string)` | <pre>[<br>  "g5.xlarge",<br>  "p4d.24xlarge"<br>]</pre> | no |
| <a name="input_gpu_max_vcpus"></a> [gpu\_max\_vcpus](#input\_gpu\_max\_vcpus) | Maximum number of vCPUs for the GPU compute environment. | `number` | `32` | no |
| <a name="input_instance_profile_arn"></a> [instance\_profile\_arn](#input\_instance\_profile\_arn) | ARN of the EC2 instance profile for Batch compute environments. Use batch\_instance\_profile\_arn from iam\_metaflow module. | `string` | n/a | yes |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | List of EC2 instance types for Batch compute environments. Optimized for general-purpose workloads. | `list(string)` | <pre>[<br>  "c5.xlarge",<br>  "c5.2xlarge",<br>  "c5.4xlarge"<br>]</pre> | no |
| <a name="input_job_role_arn"></a> [job\_role\_arn](#input\_job\_role\_arn) | ARN of the IAM role for Batch jobs. Use batch\_job\_role\_arn from iam\_metaflow module. | `string` | n/a | yes |
| <a name="input_max_vcpus"></a> [max\_vcpus](#input\_max\_vcpus) | Maximum number of vCPUs for the compute environment. Controls the maximum scale of your Batch jobs. | `number` | `16` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A mandatory prefix used for naming all Batch resources (e.g., metaflow-prod, data-science-dev). | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to Batch compute environments. | `list(string)` | n/a | yes |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | ARN of the Batch service role. Use batch\_service\_role\_arn from iam\_metaflow module. | `string` | n/a | yes |
| <a name="input_spot_bid_percentage"></a> [spot\_bid\_percentage](#input\_spot\_bid\_percentage) | The maximum percentage of On-Demand pricing to pay for Spot instances (1-100). | `number` | `50` | no |
| <a name="input_spot_fleet_role_arn"></a> [spot\_fleet\_role\_arn](#input\_spot\_fleet\_role\_arn) | ARN of the Spot Fleet role for Spot instances. Use spot\_fleet\_role\_arn from iam\_metaflow module | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for Batch compute environments. Use public subnets from vpc\_metaflow module. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of AWS tags to apply to all Batch resources for cost allocation and identification. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compute_environments"></a> [compute\_environments](#output\_compute\_environments) | Map of all compute environments created and their attributes. |
| <a name="output_default_job_definition_arn"></a> [default\_job\_definition\_arn](#output\_default\_job\_definition\_arn) | ARN of the default job definition. |
| <a name="output_default_job_definition_name"></a> [default\_job\_definition\_name](#output\_default\_job\_definition\_name) | Name of the default job definition. |
| <a name="output_default_job_queue_arn"></a> [default\_job\_queue\_arn](#output\_default\_job\_queue\_arn) | ARN of the default job queue. Use this for Metaflow configuration. |
| <a name="output_default_job_queue_name"></a> [default\_job\_queue\_name](#output\_default\_job\_queue\_name) | Name of the default job queue. Use this for Metaflow configuration. |
| <a name="output_gpu_compute_environment_arn"></a> [gpu\_compute\_environment\_arn](#output\_gpu\_compute\_environment\_arn) | ARN of the GPU compute environment. Only available if enable\_gpu\_compute\_environment is true. |
| <a name="output_gpu_job_queue_arn"></a> [gpu\_job\_queue\_arn](#output\_gpu\_job\_queue\_arn) | ARN of the GPU job queue. Only available if enable\_gpu\_compute\_environment is true. |
| <a name="output_gpu_job_queue_name"></a> [gpu\_job\_queue\_name](#output\_gpu\_job\_queue\_name) | Name of the GPU job queue. Only available if enable\_gpu\_compute\_environment is true. |
| <a name="output_job_definitions"></a> [job\_definitions](#output\_job\_definitions) | Map of all job definitions created and their attributes. |
| <a name="output_job_queues"></a> [job\_queues](#output\_job\_queues) | Map of all job queues created and their attributes. |
| <a name="output_metaflow_batch_job_definition"></a> [metaflow\_batch\_job\_definition](#output\_metaflow\_batch\_job\_definition) | The job definition ARN to use in Metaflow configuration. |
| <a name="output_metaflow_batch_job_queue"></a> [metaflow\_batch\_job\_queue](#output\_metaflow\_batch\_job\_queue) | The job queue name to use in Metaflow configuration. |
| <a name="output_ondemand_compute_environment_arn"></a> [ondemand\_compute\_environment\_arn](#output\_ondemand\_compute\_environment\_arn) | ARN of the On-Demand compute environment. |
| <a name="output_spot_compute_environment_arn"></a> [spot\_compute\_environment\_arn](#output\_spot\_compute\_environment\_arn) | ARN of the Spot compute environment. Only available if enable\_spot\_compute\_environment is true. |
<!-- END_TF_DOCS -->
