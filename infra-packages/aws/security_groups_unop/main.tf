# shared-modules/wrapped/security_groups_unop/main.tf

# tflint-ignore: terraform_naming_convention
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"


  name        = "${var.project_prefix}-${var.context_name}-sg"
  description = "SG for ${var.context_name} in ${var.project_prefix}"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, var.additional_tags)

  # Pass-through rules
  ingress_with_source_security_group_id = var.ingress_with_source_security_group_id
  ingress_with_cidr_blocks              = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks               = var.egress_with_cidr_blocks
  egress_with_source_security_group_id  = var.egress_with_source_security_group_id
}
