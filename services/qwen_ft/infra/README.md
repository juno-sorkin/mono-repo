#### Qwen Fine-Tuning Infrastructure

This directory contains the Terraform code to provision the AWS infrastructure for running Qwen fine-tuning jobs with Metaflow on AWS Batch.

## Overview

The infrastructure is built using a set of shared Terraform modules from the `infra-packages/aws` directory. It creates the following resources:

- **VPC**: A VPC with public and private subnets to host the infrastructure.
- **IAM Roles**: Necessary IAM roles for AWS Batch, EC2 instances, and Spot Fleet, all managed centrally by the `iam_metaflow` module.
- **S3 Bucket**: An S3 bucket to store Metaflow artifacts and data.
- **ECR Repository**: An ECR repository to store the container images for the fine-tuning jobs.
- **AWS Batch**: AWS Batch compute environments (including Spot for cost savings), a job queue, and a job definition for running Metaflow jobs.

## Usage

1.  **Configure the Backend**: Update `backend.tf` with the name of your S3 bucket and DynamoDB table for storing the Terraform state.

2.  **Define Input Variables**: Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values for your environment. You can see the available variables and their descriptions in `variables.tf`.

3.  **Initialize and Apply Terraform**:

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

## Inputs and Outputs

-   **Inputs**: See `variables.tf` for a complete list of input variables. Key variables for configuring the compute environment are also documented in `Terraform.tfvars`.
-   **Outputs**: See `outputs.tf` for a complete list of outputs.

## GPU Configuration

This infrastructure is configured by default to use GPU instances suitable for fine-tuning large language models. You can customize the GPU instance types and scaling parameters in your `Terraform.tfvars` file:

-   `enable_gpu_compute_environment`: Set to `true` to create a GPU-enabled AWS Batch compute environment.
-   `gpu_instance_types`: A list of GPU instance types to use (e.g., `["g5.xlarge", "p4d.24xlarge"]`).
-   `gpu_max_vcpus`: The maximum number of vCPUs the GPU environment can scale to.
#### run pre-commit hooks for to fill populate with terraform-docs
