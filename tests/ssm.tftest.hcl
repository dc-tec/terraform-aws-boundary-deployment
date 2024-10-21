mock_provider "aws" {
  mock_resource "aws_launch_template" {
    defaults = {
      id = "lt-12345678"
    }
  }
  mock_resource "aws_lb_listener" {
    defaults = {
      arn = "arn:aws:alb:::listener"
    }
  }
  mock_resource "aws_lb" {
    defaults = {
      arn      = "arn:aws:alb:::lb"
      dns_name = "test-alb-1234567890.us-west-2.elb.amazonaws.com"
      zone_id  = "Z1H1FL5HABSF5"
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
  use_ssm            = true
  create_vpc         = false
  vpc_id             = "vpc-12345678"
  private_subnet_ids = ["subnet-12345678", "subnet-23456789"]
}

run "ssm_vpc_endpoints" {
  assert {
    condition = (
      length(aws_vpc_endpoint.ssm) == 1 &&
      length(aws_vpc_endpoint.ssmmessages) == 1 &&
      length(aws_vpc_endpoint.ec2messages) == 1
    )
    error_message = "SSM VPC endpoints should be created when use_ssm is true"
  }
}

run "ssm_vpc_endpoint_configuration" {
  assert {
    condition = (
      aws_vpc_endpoint.ssm[0].vpc_id == var.vpc_id &&
      aws_vpc_endpoint.ssm[0].vpc_endpoint_type == "Interface" &&
      length(aws_vpc_endpoint.ssm[0].subnet_ids) == length(var.private_subnet_ids) &&
      contains(aws_vpc_endpoint.ssm[0].security_group_ids, aws_security_group.boundary_controller.id) &&
      contains(aws_vpc_endpoint.ssm[0].security_group_ids, aws_security_group.boundary_worker.id)
    )
    error_message = "SSM VPC endpoint should have correct configuration"
  }
}

run "ssm_iam_policies" {
  assert {
    condition = (
      length(aws_iam_role_policy.ssm_controller) == 1 &&
      length(aws_iam_role_policy.ssm_worker) == 1
    )
    error_message = "SSM IAM policies should be created for controller and worker roles"
  }
}
