# terraform.tfvars.example

# A prefix for all resources created (e.g., 'qwen-ft-prod').
name_prefix = "qwen-ft-dev"

# The AWS region to deploy resources into.
aws_region = "us-east-2"

# The CIDR block for the VPC.
vpc_cidr_block = "10.0.0.0/16"

# The single AWS Availability Zone into which all network resources will be deployed (e.g., us-east-2a).
availability_zone = "us-east-2a"

# The name of the S3 bucket for Metaflow data.
s3_bucket_name = "your-metaflow-s3-bucket-name" ## FIXME

# The name of the ECR repository for the job container images.
ecr_repository_name = "qwen-ft-jobs" ## FIXME

# Default container image for Metaflow jobs. Uses AWS Deep Learning Container by default.
default_container_image = "763104351884.dkr.ecr.us-east-2.amazonaws.com/pytorch-training:1.13.1-gpu-py39-cu117-ubuntu20.04-sagemaker" ### FIXME

# A map of tags to apply to all resources.
tags = {
  Environment = "dev"
  Project     = "qwen-ft"
}

# --- Optional Compute Environment Settings ---

# Enable GPU support for fine-tuning jobs.
enable_gpu_compute_environment = true

# Use powerful GPU instances suitable for large model fine-tuning.
gpu_instance_types = ["g5.xlarge", "p4d.24xlarge"]

# Allocate a higher number of vCPUs for the GPU environment to handle demanding workloads.
gpu_max_vcpus = 128
