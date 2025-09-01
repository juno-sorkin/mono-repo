# services/qwen_ft/infra/main.tf

module "vpc" {
  source = "../../../infra-packages/aws/vpc_metaflow"

  name_prefix       = var.name_prefix
  vpc_cidr_block    = var.vpc_cidr_block
  availability_zone = var.availability_zone

  tags = var.tags
}

module "iam" {
  source = "../../../infra-packages/aws/iam_metaflow"

  name_prefix            = var.name_prefix
  enable_spot_fleet_role = var.enable_spot_fleet_role
  tags                   = var.tags
}

module "s3" {
  source = "../../../infra-packages/aws/s3_metaflow"

  bucket_name  = var.s3_bucket_name
  job_role_arn = module.iam.batch_job_role_arn
  vpc_id       = module.vpc.vpc_id
  tags         = var.tags
}

module "ecr" {
  source = "../../../infra-packages/aws/ecr_unop"

  repository_name = var.ecr_repository_name
  job_role_arn    = module.iam.batch_job_role_arn
  attach_policy   = var.ecr_attach_policy
  tags            = var.tags
}

module "batch" {
  source = "../../../infra-packages/aws/batch_metaflow"

  name_prefix                     = var.name_prefix
  subnet_ids                      = module.vpc.public_subnets
  security_group_ids              = [module.vpc.default_security_group_id]
  job_role_arn                    = module.iam.batch_job_role_arn
  instance_profile_arn            = module.iam.batch_instance_profile_arn
  service_role_arn                = module.iam.batch_service_role_arn
  spot_fleet_role_arn             = module.iam.spot_fleet_role_arn
  default_container_image         = var.default_container_image
  enable_spot_compute_environment = var.enable_spot_compute_environment
  spot_bid_percentage             = var.spot_bid_percentage
  max_vcpus                       = var.max_vcpus
  instance_types                  = var.instance_types
  enable_gpu_compute_environment  = var.enable_gpu_compute_environment
  gpu_instance_types              = var.gpu_instance_types
  gpu_max_vcpus                   = var.gpu_max_vcpus
  aws_region                      = var.aws_region
  tags                            = var.tags
}
