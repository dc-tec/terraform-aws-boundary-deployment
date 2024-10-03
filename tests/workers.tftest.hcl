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

run "worker_9202_self" {
  assert {
    condition = aws_security_group_rule.boundary_worker_allow_9202_self.from_port == 9202 && aws_security_group_rule.boundary_worker_allow_9202_self.to_port == 9202

    error_message = "Expected the from_port and to_port to be 9202"
  }
}

run "worker_to_users_9202" {
  assert {
    condition = aws_security_group_rule.boundary_worker_allow_9202_users.from_port == 9202 && aws_security_group_rule.boundary_worker_allow_9202_users.to_port == 9202

    error_message = "Expected the from_port and to_port to be 9202"
  }
}

run "worker_launch_template_security_group" {
  assert {
    condition = contains(aws_launch_template.boundary_worker.vpc_security_group_ids,aws_security_group.boundary_worker.id)

    error_message = "Expected the launch template to use the worker security group"
  }
}

run "worker_launch_template_instance_profile" {
  assert {
    condition = aws_launch_template.boundary_worker.iam_instance_profile[0].name == aws_iam_instance_profile.boundary_worker.name

    error_message = "Expected the launch template to use the worker instance profile"
  }
}

run "worker_launch_template_metadata_http_enabled" {
  assert {
    condition = aws_launch_template.boundary_worker.metadata_options[0].http_endpoint == "enabled"

    error_message = "HTTP Endpoint should be enabled"
  }
}

run "worker_asg_launch_template" {
  assert {
    condition = aws_autoscaling_group.boundary_worker.launch_template[0].id == aws_launch_template.boundary_worker.id

    error_message = "Expected the autoscaling group to use the worker launch template"
  }
}



