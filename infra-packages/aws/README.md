# AWS Infrastructure Packages

This directory contains reusable Terraform modules for AWS infrastructure components used across the organization.

## Available Modules

### 1. Batch Metaflow
- Location: `batch_metaflow/`
- Purpose: Sets up AWS Batch infrastructure for Metaflow workflows
- Main components: Batch compute environment, job queue, IAM roles

### 2. ECR Unop
- Location: `ecr_unop/`
- Purpose: Creates Elastic Container Registry repositories with standardized configurations
- Features: Lifecycle policies, scanning configurations, repository policies

### 3. IAM Metaflow
- Location: `iam_metaflow/`
- Purpose: IAM roles and policies for Metaflow execution
- Includes: Task execution roles, access policies for related services

### 4. S3 Metaflow
- Location: `s3_metaflow/`
- Purpose: S3 buckets for Metaflow artifacts and data
- Configurations: Versioning, encryption, lifecycle policies

### 5. Security Groups Unop
- Location: `security_groups_unop/`
- Purpose: Standard security group configurations
- Includes: Common ingress/egress rules for various service types

## Usage

Each module can be used independently by referencing its path:
```hcl
module "example" {
  source = "path/to/module"

  # Module-specific variables
}
```

Refer to individual module READMEs for detailed documentation on inputs, outputs, and usage examples.

## Development

- All modules follow standard Terraform module structure
- Each includes:
  - `main.tf`: Primary resource definitions
  - `variables.tf`: Input variables
  - `outputs.tf`: Module outputs
  - `tests/`: Integration tests

## Versioning

Modules are versioned using Git tags following semantic versioning (e.g., v1.0.0).
