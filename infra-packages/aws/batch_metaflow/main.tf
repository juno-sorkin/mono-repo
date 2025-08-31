# infra-packages/aws/batch_metaflow/main.tf

locals {
  common_tags = merge(var.tags, {
    Terraform = "true"
    Module    = "batch_metaflow"
  })

  # Base compute environment configuration
  base_compute_resources = {
    type               = "EC2"
    min_vcpus          = 0 # Cost-effective: no idle instances
    max_vcpus          = var.max_vcpus
    desired_vcpus      = 0 # Start with zero instances
    instance_types     = var.instance_types
    security_group_ids = var.security_group_ids
    subnets            = var.subnet_ids
    instance_role      = var.instance_profile_arn
    tags = merge(local.common_tags, {
      Name = "${var.name_prefix}-batch-instance"
      Type = "OnDemand"
    })
  }

  # Spot compute environment configuration
  spot_compute_resources = var.enable_spot_compute_environment ? {
    type                = "SPOT"
    allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
    bid_percentage      = var.spot_bid_percentage
    min_vcpus           = 0
    max_vcpus           = var.max_vcpus
    desired_vcpus       = 0
    instance_types      = var.instance_types
    security_group_ids  = var.security_group_ids
    subnets             = var.subnet_ids
    instance_role       = var.instance_profile_arn
    spot_iam_fleet_role = var.spot_fleet_role_arn
    tags = merge(local.common_tags, {
      Name = "${var.name_prefix}-batch-spot-instance"
      Type = "Spot"
    })
  } : null

  # GPU compute environment configuration
  gpu_compute_resources = var.enable_gpu_compute_environment ? {
    type               = "EC2"
    min_vcpus          = 0
    max_vcpus          = var.gpu_max_vcpus
    desired_vcpus      = 0
    instance_types     = var.gpu_instance_types
    security_group_ids = var.security_group_ids
    subnets            = var.subnet_ids
    instance_role      = var.instance_profile_arn
    tags = merge(local.common_tags, {
      Name = "${var.name_prefix}-batch-gpu-instance"
      Type = "GPU"
    })
  } : null
}

module "batch" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-batch.git?ref=v3.0.4"



  # --- Compute Environments ---
  compute_environments = merge(
    # On-Demand compute environment
    {
      ondemand = {
        name_prefix       = "${var.name_prefix}-ondemand"
        service_role      = var.service_role_arn
        compute_resources = local.base_compute_resources
        state             = "ENABLED"
        type              = "MANAGED"
        tags              = local.common_tags
      }
    },
    # Spot compute environment (conditional)
    var.enable_spot_compute_environment ? {
      spot = {
        name_prefix       = "${var.name_prefix}-spot"
        service_role      = var.service_role_arn
        compute_resources = local.spot_compute_resources
        state             = "ENABLED"
        type              = "MANAGED"
        tags              = local.common_tags
      }
    } : {},
    # GPU compute environment (conditional)
    var.enable_gpu_compute_environment ? {
      gpu = {
        name_prefix       = "${var.name_prefix}-gpu"
        service_role      = var.service_role_arn
        compute_resources = local.gpu_compute_resources
        state             = "ENABLED"
        type              = "MANAGED"
        tags              = local.common_tags
      }
    } : {}
  )

  # --- Job Queues ---
  job_queues = merge(
    # Default job queue (prioritizes Spot, falls back to On-Demand)
    {
      default = {
        name     = "${var.name_prefix}-default"
        state    = "ENABLED"
        priority = 100
        compute_environment_order = merge(
          var.enable_spot_compute_environment ? {
            0 = {
              compute_environment_key = "spot"
            }
          } : {},
          {
            1 = {
              compute_environment_key = "ondemand"
            }
          }
        )
        tags = merge(local.common_tags, {
          JobQueue = "Default Metaflow job queue"
        })
      }
    },
    # GPU job queue (if GPU compute environment is enabled)
    var.enable_gpu_compute_environment ? {
      gpu = {
        name     = "${var.name_prefix}-gpu"
        state    = "ENABLED"
        priority = 200
        compute_environment_order = {
          0 = {
            compute_environment_key = "gpu"
          }
        }
        tags = merge(local.common_tags, {
          JobQueue = "GPU Metaflow job queue"
        })
      }
    } : {}
  )

  # --- Job Definitions ---
  job_definitions = {
    metaflow_default = {
      name           = "${var.name_prefix}-default"
      propagate_tags = true

      container_properties = jsonencode({
        image      = var.default_container_image
        jobRoleArn = var.job_role_arn

        # Default resource requirements for Metaflow
        resourceRequirements = [
          { type = "VCPU", value = "4" },
          { type = "MEMORY", value = "16" }
        ]

        # CloudWatch logging configuration
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/aws/batch/${var.name_prefix}"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "metaflow"
          }
        }

        # Environment variables for Metaflow
        environment = [
          { name = "METAFLOW_BATCH_JOB_QUEUE", value = "${var.name_prefix}-default" },
          { name = "METAFLOW_ECS_S3_ACCESS_IAM_ROLE", value = var.job_role_arn }
        ]
      })

      retry_strategy = {
        attempts = 3
      }

      timeout = {
        attempt_duration_seconds = 3600 # 1 hour timeout
      }

      tags = merge(local.common_tags, {
        JobDefinition = "Default Metaflow job definition"
      })
    }
  }

  # Disable IAM role creation since we're using external roles
  ## TODO: check to make sure this is consistent with how want to do this
  create_instance_iam_role   = false
  create_service_iam_role    = false
  create_spot_fleet_iam_role = false

  tags = local.common_tags
}
