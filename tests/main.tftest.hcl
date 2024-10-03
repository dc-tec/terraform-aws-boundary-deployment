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
  vpc_id = "vpc-12345678"
  name = "boundary"
  tags = {
    "Terraform-Test" = "true"
  }
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2k4t5N5G4d1Zqg2t+I0j9V3nLb7R"
  aws_route53_zone = "Z12345678"
  private_subnet_ids = ["subnet-12345678", "subnet-23456789"]
  public_subnet_ids = ["subnet-34567890", "subnet-45678901"]
  private_subnet_cidr_blocks = ["10.10.10.0/24"]
}

run "controller_lb_9200" {
  assert {
    condition = aws_security_group_rule.boundary_controller_allow_9200_lb.from_port == 9200 && aws_security_group_rule.boundary_controller_allow_9200_lb.to_port == 9200

    error_message = "Expected the from_port and to_port to be 9200"
  }
}
