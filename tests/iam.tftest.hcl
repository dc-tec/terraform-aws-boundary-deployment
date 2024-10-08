mock_provider "aws" {
  mock_resource "aws_launch_template" {
    defaults = {
      id = "lt-12345678"
    }
  }
  mock_resource "aws_lb_listener" {
    defaults = {
      arn = "arn:aws:alb:::listener"
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
  mock_resource "aws_kms_key" {
    defaults = {
      arn = "arn:aws:kms:::key"
    }
  }
}

variables {
  vpc_id = "vpc-12345678"
  name = "boundary"
  tags = {
    "Terraform-Test" = "true"
  }
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2k4t5N5G4d1Zqg2t+I0j9V3nLb7R"
  aws_route53_zone = "Z12345678"
  private_subnet_ids = ["subnet-12345678", "subnet-23456789"]
  public_subnet_ids = ["subnet-34567890", "subnet-45678901"]
  private_subnet_cidr_blocks = ["10.10.10.0/24", "10.10.11.0/24"]
  use_acm = false
  use_ssm = true
  use_cloudwatch = true
  logging_enabled = true
  boundary_admin_users = [
    "admin1",
    "admin2"
  ]
}

run "verify_cloudwatch_policies" {
  assert {
    condition     = length(aws_iam_role_policy.cloudwatch_controller) == 1
    error_message = "CloudWatch policy for controller should be created when use_cloudwatch is true"
  }

  assert {
    condition     = length(aws_iam_role_policy.cloudwatch_worker) == 1
    error_message = "CloudWatch policy for worker should be created when use_cloudwatch is true"
  }
}

run "verify_ssm_policies" {
  assert {
    condition     = length(aws_iam_role_policy.ssm_controller) == 1
    error_message = "SSM policy for controller should be created when use_ssm is true"
  }

  assert {
    condition     = length(aws_iam_role_policy.ssm_worker) == 1
    error_message = "SSM policy for worker should be created when use_ssm is true"
  }
}

run "verify_boundary_admin_group_policy" {
  assert {
    condition     = length(aws_iam_group_policy.boundary_admin) == 1
    error_message = "Boundary admin group policy should be created when use_ssm is true"
  }
}
