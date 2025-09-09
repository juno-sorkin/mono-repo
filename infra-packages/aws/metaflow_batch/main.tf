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
    source = "git::https://github.com/outerbounds/terraform-aws-metaflow/modules/computation.git?ref=v0.12.1"



batch_type = EC2
# no warm pool
compute_environment_desired_vcpus = 0


}

