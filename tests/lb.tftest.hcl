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
  use_acm = false
}

run "lb_allow_9200" {
  assert {
    condition = aws_security_group_rule.boundary_lb_allow_9200.from_port == 9200 && aws_security_group_rule.boundary_lb_allow_9200.to_port == 9200 && aws_security_group_rule.boundary_lb_allow_9200.security_group_id == aws_security_group.boundary_lb.id

    error_message = "Expected the from_port and to_port to be 9200"
  }
}

run "lb_type_network" {
  assert {
    condition = aws_lb.boundary_lb.load_balancer_type == "network"

    error_message = "Expected the load balancer type to be network"
  }
}

# TODO: I do not like this test, works for now tho, should revist
run "lb_public_subnets" {
  assert {
    condition = (
      length(aws_lb.boundary_lb.subnets) == length(var.public_subnet_ids) &&
      setintersection(aws_lb.boundary_lb.subnets, var.public_subnet_ids) == toset(var.public_subnet_ids)
    )

    error_message = "Load balancer subnets do not match the expected public subnet IDs"
  }
}

run "lb_target_group_9200" {
  assert {
    condition = aws_lb_target_group.boundary_lb.port == 9200

    error_message = "Expected the target group port to be 9200"
  }
}

run "lb_listener_9200" {
  assert {
    condition = aws_lb_listener.boundary_lb.port == 9200

    error_message = "Expected the listener port to be 9200"
  }
}

run "lb_listener_lb_association" {
  assert {
    condition = aws_lb_listener.boundary_lb.load_balancer_arn == aws_lb.boundary_lb.arn

    error_message = "Expected the listener to be associated with the load balancer"
  }
}

run "lb_listener_default_action" {
  assert {
    condition = aws_lb_listener.boundary_lb.default_action[0].type == "forward" && aws_lb_listener.boundary_lb.default_action[0].target_group_arn == aws_lb_target_group.boundary_lb.arn

    error_message = "Expected the listener to forward to the target group"
  }
}

run "lb_allow_9201" {
  assert {
    condition = aws_security_group_rule.boundary_lb_allow_9201.from_port == 9201 && aws_security_group_rule.boundary_lb_allow_9201.to_port == 9201 && aws_security_group_rule.boundary_lb_allow_9201.security_group_id == aws_security_group.boundary_lb.id

    error_message = "Expected the from_port and to_port to be 9201"
  }
}

run "lb_target_group_9201" {
  assert {
    condition = aws_lb_target_group.boundary_lb_worker.port == 9201

    error_message = "Expected the target group port to be 9201"
  }
}
