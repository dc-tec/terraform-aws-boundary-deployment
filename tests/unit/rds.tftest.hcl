mock_provider "aws" {
  mock_resource "aws_launch_template" {
    defaults = {
      id = "lt-12345678"
    }
  }
  mock_resource "aws_lb_listener" {
    defaults = {
      arn      = "arn:aws:alb:::listener"
      dns_name = "test-alb-1234567890.us-west-2.elb.amazonaws.com"
    }
  }
  mock_resource "aws_lb" {
    defaults = {
      arn = "arn:aws:alb:::lb"
    }
  }
  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:alb:::alb_target_group"
    }
  }
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:::certificate"
    }
  }
}

variables {
  name = "boundary"
  tags = {
    "Terraform-Test" = "true"
  }
  db_instance_class          = "db.t3.micro"
  db_engine_version          = "16.4"
  db_allocated_storage       = 20
  db_backup_enabled          = true
  db_backup_window           = "03:00-06:00"
  db_backup_retention_period = 7
  db_multi_az                = true
  db_username                = "boundary"
  create_vpc                 = false
  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-12345678", "subnet-23456789"]
}

run "rds_instance_configuration" {
  assert {
    condition = (
      aws_db_instance.boundary_db.engine == "postgres" &&
      aws_db_instance.boundary_db.engine_version == var.db_engine_version &&
      aws_db_instance.boundary_db.instance_class == var.db_instance_class &&
      aws_db_instance.boundary_db.allocated_storage == var.db_allocated_storage &&
      aws_db_instance.boundary_db.db_name == "boundary" &&
      aws_db_instance.boundary_db.multi_az == var.db_multi_az
    )
    error_message = "RDS instance should have correct configuration"
  }
}

run "rds_backup_configuration" {
  assert {
    condition = (
      aws_db_instance.boundary_db.backup_retention_period == var.db_backup_retention_period &&
      aws_db_instance.boundary_db.backup_window == var.db_backup_window
    )
    error_message = "RDS instance should have correct backup configuration"
  }
}

run "rds_security_group" {
  assert {
    condition = (
      aws_security_group_rule.boundary_controller_to_db.from_port == 5432 &&
      aws_security_group_rule.boundary_controller_to_db.to_port == 5432 &&
      aws_security_group_rule.boundary_controller_to_db.source_security_group_id == aws_security_group.boundary_controller.id
    )
    error_message = "Security group rule should allow controller to access RDS on port 5432"
  }
}

run "rds_subnet_group" {
  assert {
    condition = (
      aws_db_subnet_group.boundary_db.name == "${var.name}-db-subnet-group" &&
      length(aws_db_subnet_group.boundary_db.subnet_ids) == length(var.private_subnet_ids)
    )
    error_message = "RDS subnet group should be created with correct name and subnets"
  }
}

run "rds_secrets_manager" {
  assert {
    condition = (
      aws_secretsmanager_secret.boundary_db_secret.name == "${var.name}-db-secret" &&
      can(jsondecode(aws_secretsmanager_secret_version.boundary_db_secret.secret_string))
    )
    error_message = "Secrets Manager secret should be created for RDS credentials"
  }
}
