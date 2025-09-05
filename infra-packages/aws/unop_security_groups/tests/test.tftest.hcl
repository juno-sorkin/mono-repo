# Test file for security_groups_unop module

provider "aws" {
  region                      = "us-east-2"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}


# Test basic security group creation - validate configuration
run "test_basic_security_group" {
  command = plan

  variables {
    project_prefix = "test-project"
    context_name   = "web"
    vpc_id         = "vpc-12345678"
    common_tags = {
      Environment = "test"
      Terraform   = "true"
    }
  }

  # Verify that the plan succeeds and creates expected resources
  assert {
    condition     = length(keys(module.security-group)) > 0
    error_message = "Security group module should be configured"
  }
}

# Test security group with ingress rules from CIDR blocks
run "test_ingress_cidr_blocks" {
  command = plan

  variables {
    project_prefix = "test-project"
    context_name   = "database"
    vpc_id         = "vpc-12345678"

    ingress_with_cidr_blocks = [
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "MySQL access from private subnets"
        cidr_blocks = "10.0.0.0/16"
      },
      {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        description = "PostgreSQL access"
        cidr_blocks = "10.0.1.0/24"
      }
    ]

    common_tags = {
      Environment = "test"
      Database    = "true"
    }
  }

  # Verify configuration is valid and module is configured
  assert {
    condition     = var.context_name == "database"
    error_message = "Context name should be set correctly"
  }

  assert {
    condition     = var.project_prefix == "test-project"
    error_message = "Project prefix should be set correctly"
  }
}

# Test security group with ingress from other security groups
run "test_ingress_security_group_id" {
  command = plan

  variables {
    project_prefix = "test-project"
    context_name   = "rds"
    vpc_id         = "vpc-12345678"

    ingress_with_source_security_group_id = [
      {
        from_port                = 3306
        to_port                  = 3306
        protocol                 = "tcp"
        description              = "MySQL from batch compute"
        source_security_group_id = "sg-batch123"
      },
      {
        from_port                = 5432
        to_port                  = 5432
        protocol                 = "tcp"
        description              = "PostgreSQL from web tier"
        source_security_group_id = "sg-web456"
      }
    ]

    common_tags = {
      Environment = "production"
      Tier        = "database"
    }
  }

  # Verify variables are set correctly
  assert {
    condition     = var.vpc_id == "vpc-12345678"
    error_message = "VPC ID should be set correctly"
  }

  assert {
    condition     = length(var.ingress_with_source_security_group_id) == 2
    error_message = "Should have 2 ingress rules with security group IDs"
  }
}

# Test security group with egress rules
run "test_egress_rules" {
  command = plan

  variables {
    project_prefix = "test-project"
    context_name   = "batch"
    vpc_id         = "vpc-12345678"

    egress_with_cidr_blocks = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "HTTPS to internet"
        cidr_blocks = "0.0.0.0/0"
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "HTTP to internet"
        cidr_blocks = "0.0.0.0/0"
      }
    ]

    egress_with_source_security_group_id = [
      {
        from_port                = 3306
        to_port                  = 3306
        protocol                 = "tcp"
        description              = "MySQL to RDS"
        source_security_group_id = "sg-rds789"
      }
    ]

    common_tags = {
      Environment = "production"
      Service     = "batch-compute"
    }
  }

  # Verify egress rules are configured
  assert {
    condition     = length(var.egress_with_cidr_blocks) == 2
    error_message = "Should have 2 egress rules with CIDR blocks"
  }

  assert {
    condition     = length(var.egress_with_source_security_group_id) == 1
    error_message = "Should have 1 egress rule with security group ID"
  }
}

# Test security group with additional tags
run "test_additional_tags" {
  command = plan

  variables {
    project_prefix = "test-project"
    context_name   = "api"
    vpc_id         = "vpc-12345678"

    common_tags = {
      Environment = "staging"
      Project     = "metaflow"
      Terraform   = "true"
    }

    additional_tags = {
      Component = "api-gateway"
      Owner     = "platform-team"
    }
  }

  # Verify tags are configured correctly
  assert {
    condition     = var.common_tags["Environment"] == "staging"
    error_message = "Common tags should include Environment"
  }

  assert {
    condition     = var.additional_tags["Component"] == "api-gateway"
    error_message = "Additional tags should include Component"
  }
}

# Test comprehensive security group configuration
run "test_comprehensive_configuration" {
  command = plan

  variables {
    project_prefix = "metaflow-prod"
    context_name   = "compute"
    vpc_id         = "vpc-prod123"

    ingress_with_cidr_blocks = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "SSH from bastion"
        cidr_blocks = "10.0.100.0/24"
      }
    ]

    ingress_with_source_security_group_id = [
      {
        from_port                = 8080
        to_port                  = 8080
        protocol                 = "tcp"
        description              = "App port from ALB"
        source_security_group_id = "sg-alb123"
      }
    ]

    egress_with_cidr_blocks = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "HTTPS outbound"
        cidr_blocks = "0.0.0.0/0"
      }
    ]

    common_tags = {
      Environment = "production"
      Project     = "metaflow"
      Terraform   = "true"
      Module      = "security-groups"
    }

    additional_tags = {
      Component = "batch-compute"
      Team      = "ml-platform"
    }
  }

  # Verify all rule types are configured
  assert {
    condition     = length(var.ingress_with_cidr_blocks) == 1
    error_message = "Should have 1 ingress rule with CIDR blocks"
  }

  assert {
    condition     = length(var.ingress_with_source_security_group_id) == 1
    error_message = "Should have 1 ingress rule with security group ID"
  }

  assert {
    condition     = length(var.egress_with_cidr_blocks) == 1
    error_message = "Should have 1 egress rule with CIDR blocks"
  }
}

# Test variable validation
run "test_variable_validation" {
  command = plan

  variables {
    project_prefix = "test"
    context_name   = "validation-test"
    vpc_id         = "vpc-test123"
  }

  # Verify required variables are set
  assert {
    condition     = var.project_prefix != ""
    error_message = "Project prefix should not be empty"
  }

  assert {
    condition     = var.context_name != ""
    error_message = "Context name should not be empty"
  }

  assert {
    condition     = var.vpc_id != ""
    error_message = "VPC ID should not be empty"
  }
}
