# infra-packages/aws/metaflow_batch/main.tf
locals {
  cpu = [
    "c6i.xlarge",
    "c6i.8xlarge",
    "c6i.16xlarge",

  ]
  small_gpu = [
    "g5.xlarge"
  ]
  large_gpu = [
    "p4d.24xlarge" # check qouta
  ]
}
module "computation" {
    source = "git::https://github.com/outerbounds/terraform-aws-metaflow.git//modules/computation?ref=v0.12.1"


  batch_type = EC2
  compute_environment_desired_vcpus = 0  # no warm pool
  compute_environment_max_vcpus = var.max_vcpu
  compute_environment_instance_types = var.instance_types
  compute_environment_min_vcpus = "Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)" #harcode probably

  resource_prefix = var.resource_prefix
  resource_suffix = var.resource_suffix
  standard_tags = var.standard_tags
  subnet1_id = var.backup_subnet_1
  subnet2_id = var.backup_subnet_2
  metaflow_vpc_id = "filler"


}

# module "datastore" {
#     source = "git::https://github.com/outerbounds/terraform-aws-metaflow.git//modules/datastore?ref=v0.12.1"

#   resource_prefix = var.resource_prefix
#   resource_suffix = var.resource_suffix
#   standard_tags = var.standard_tags
#   subnet1_id = var.backup_subnet_1
#   subnet2_id = var.backup_subnet_2
#   metaflow_vpc_id = "filler"

#   metadata_service_security_group_id = "filler"


# }


module "unop_vpc" {
  source = "../unop_vpc"

name_prefix = "filler"
vpc_cidr_block = "filler"
}
