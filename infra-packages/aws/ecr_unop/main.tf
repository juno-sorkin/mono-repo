# infra-packages/aws/ecr_unop/main.tf

locals {
  default_lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Expire untagged images older than 14 days",
      selection = {
        tagStatus   = "untagged",
        countType   = "sinceImagePushed",
        countUnit   = "days",
        countNumber = 14
      },
      action = {
        type = "expire"
      }
    }]
  })

  default_tags = {
    managed_by = "terraform",
    project    = "metaflow"
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "3.0.1"


  repository_name                 = var.repository_name
  repository_type                 = "private"
  repository_image_tag_mutability = var.image_tag_mutability
  repository_force_delete         = var.force_delete

  # Lifecycle policy configuration
  create_lifecycle_policy     = true
  repository_lifecycle_policy = coalesce(var.lifecycle_policy_json, local.default_lifecycle_policy)

  # The decision to attach a policy is controlled by a boolean variable to avoid a dependency cycle.
  # The count of a resource cannot depend on an attribute (like an ARN) that is only known after apply.
  attach_repository_policy          = var.attach_policy
  repository_read_write_access_arns = var.attach_policy ? [var.job_role_arn] : []

  tags = merge(local.default_tags, var.tags)
}
