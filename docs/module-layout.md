# Terraform Modules Documentation

This document provides an overview of the Terraform modules available in this shared modules repository.

## Module Categories

### Custom Modules (`shared-modules/custom/`)

These are custom-built Terraform modules that provide reusable infrastructure components:

#### Networking
- **`vpc/`** - Creates a flexible AWS VPC with public and private subnets, NAT gateways, and configurable routing
- **`security-group/`** - Manages AWS security groups with standardized naming and tagging

#### Compute
- **`asg-instance/`** - Auto Scaling Group with EC2 instances
- **`sagemaker-notebook-instance/`** - SageMaker notebook instances for ML development
- **`sagemaker-endpoint/`** - SageMaker endpoints for model deployment

#### Storage
- **`s3-bucket/`** - S3 bucket with security and lifecycle configurations
- **`efs/`** - Elastic File System for shared storage

#### Identity & Access Management
- **`iam-role/`** - IAM roles with configurable policies

#### Application Load Balancing
- **`alb/`** - Application Load Balancer with target groups and listeners

#### AI/ML
- **`model-cache/`** - Infrastructure for ML model caching and storage

### Wrapped Modules (`shared-modules/wrapped/`)

These modules wrap popular community Terraform modules with opinionated configurations:

#### Metaflow Infrastructure
- **`vpc_metaflow/`** - VPC specifically configured for Metaflow deployments
- **`s3_metaflow/`** - S3 bucket configured for Metaflow artifact storage
- **`iam_metaflow/`** - IAM roles and policies for Metaflow on AWS Batch
- **`batch_metaflow/`** - AWS Batch compute environment for Metaflow workflows

#### Utility Modules
- **`security_groups_unop/`** - Standardized security group creation
- **`ecr_unop/`** - Private ECR repository management

## Module Standards

All modules in this repository follow these standards:

### Documentation
- Each module includes a comprehensive `README.md` with:
  - Clear module description and purpose
  - Example usage with HCL code blocks
  - Input and output parameter documentation
  - Requirements and dependencies

### Testing
- Modules include `.tftests.hcl` files for automated testing
- Tests validate module functionality and integration

### Code Quality
- Consistent Terraform formatting
- Proper resource naming conventions
- Standardized tagging
- Security best practices

### Version Management
- Each module includes a `versions.tf` file specifying Terraform and provider version constraints

## Usage Examples

### Basic Module Usage
```hcl
module "vpc" {
  source = "github.com/juno-sorkin/tf-shared-modules//shared-modules/custom/vpc?ref=v1.0.0"

  name = "my-app-vpc"
  cidr = "10.0.0.0/16"

  public_subnets = [
    { az = "us-east-1a", cidr_block = "10.0.1.0/24" },
    { az = "us-east-1b", cidr_block = "10.0.2.0/24" }
  ]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Metaflow Infrastructure
```hcl
module "vpc_metaflow" {
  source = "github.com/juno-sorkin/tf-shared-modules//shared-modules/wrapped/vpc_metaflow?ref=v1.0.0"

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

## Contributing

When adding new modules or updating existing ones:

1. Follow the established directory structure
2. Include comprehensive documentation
3. Add automated tests
4. Ensure all code passes linting and formatting checks
5. Update this documentation to reflect new modules

## Module Development Guidelines

- Use semantic versioning for module releases
- Pin module sources to specific Git tags or commits
- Document breaking changes clearly
- Test modules across multiple environments when possible
- Follow Terraform best practices and security guidelines
