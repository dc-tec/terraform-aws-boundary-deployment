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
  vpc_id = "vpc-12345678"
  name   = "boundary"
  tags = {
    "Terraform-Test" = "true"
  }
  ssh_public_key             = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2k4t5N5G4d1Zqg2t+I0j9V3nLb7R"
  aws_route53_zone           = "Z12345678"
  private_subnet_ids         = ["subnet-12345678", "subnet-23456789"]
  public_subnet_ids          = ["subnet-34567890", "subnet-45678901"]
  private_subnet_cidr_blocks = ["10.10.10.0/24", "10.10.11.0/24"]
  use_acm                    = false
}

run "controller_to_lb_9200" {
  assert {
    condition = aws_security_group_rule.boundary_controller_allow_9200_lb.from_port == 9200 && aws_security_group_rule.boundary_controller_allow_9200_lb.to_port == 9200

    error_message = "Expected the from_port and to_port to be 9200"
  }
}

run "controller_to_lb_connected" {
  assert {
    condition = aws_security_group_rule.boundary_controller_allow_9200_lb.source_security_group_id == aws_security_group.boundary_lb.id

    error_message = "Controller needs to be able to communicate with the load balancer"
  }
}

run "controller_api_self" {
  assert {
    condition = aws_security_group_rule.boundary_controller_api_self.self == true && aws_security_group_rule.boundary_controller_api_self.security_group_id == aws_security_group.boundary_controller.id

    error_message = "The controller needs to communicate with itself"
  }
}

run "controller_to_worker_9201" {
  assert {
    condition = aws_security_group_rule.allow_9201_boundary_workers_direct.from_port == 9201 && aws_security_group_rule.allow_9201_boundary_workers_direct.to_port == 9201

    error_message = "Expected the from_port and to_port to be 9201"
  }
}

run "controller_to_worker_connected" {
  assert {
    condition = aws_security_group_rule.allow_9201_boundary_workers_direct.source_security_group_id == aws_security_group.boundary_worker.id

    error_message = "Controller needs to be able to communicate with the worker"
  }
}

run "controller_health_9203" {
  assert {
    condition = aws_security_group_rule.boundary_controller_health_allow_9203.from_port == 9203 && aws_security_group_rule.boundary_controller_health_allow_9203.to_port == 9203

    error_message = "Expected the from_port and to_port to be 9203"
  }
}

run "controller_launch_template_security_group" {
  assert {
    condition = contains(aws_launch_template.boundary_controller.vpc_security_group_ids, aws_security_group.boundary_controller.id)

    error_message = "Launch template needs to be associated with the controller security group"
  }
}

run "controller_launch_template_instance_profile" {
  assert {
    condition = aws_launch_template.boundary_controller.iam_instance_profile[0].name == aws_iam_instance_profile.boundary_controller.name

    error_message = "Launch template needs to be associated with the controller instance profile"
  }
}

run "controller_launch_template_metadata_http_enabled" {
  assert {
    condition = aws_launch_template.boundary_controller.metadata_options[0].http_endpoint == "enabled"

    error_message = "HTTP Endpoint should be enabled"
  }
}

run "controller_asg_target_groups" {
  assert {
    condition = contains(aws_autoscaling_group.boundary_controller.target_group_arns, aws_lb_target_group.boundary_lb_controller.arn) && contains(aws_autoscaling_group.boundary_controller.target_group_arns, aws_lb_target_group.boundary_lb_worker.arn)

    error_message = "ASG needs to be associated with the Controller and Worker target groups"
  }
}

run "controller_asg_launch_template" {
  assert {
    condition = aws_autoscaling_group.boundary_controller.launch_template[0].id == aws_launch_template.boundary_controller.id

    error_message = "ASG needs to be associated with the Controller launch template"
  }
}
