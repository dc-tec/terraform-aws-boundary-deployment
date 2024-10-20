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
  vpc_id = "vpc-12345678"
  name   = "boundary"
  tags = {
    "Terraform-Test" = "true"
  }
  aws_route53_zone           = "Z12345678"
  private_subnet_ids         = ["subnet-12345678", "subnet-23456789"]
  private_subnet_cidr_blocks = ["10.0.0.0/16", "10.1.0.0/16"]
  public_subnet_ids          = ["subnet-34567890", "subnet-45678901"]
  boundary_a_record          = "boundary.example.com"
  use_acm                    = false
}

run "lb_security_group" {
  assert {
    condition     = aws_security_group.boundary_lb.vpc_id == var.vpc_id
    error_message = "Load balancer security group should be in the specified VPC"
  }
}

run "lb_allow_443" {
  assert {
    condition     = aws_security_group_rule.boundary_lb_allow_443.from_port == 443 && aws_security_group_rule.boundary_lb_allow_443.to_port == 443
    error_message = "Load balancer should allow inbound traffic on port 443"
  }
}

run "lb_allow_9201" {
  assert {
    condition     = aws_security_group_rule.boundary_lb_allow_9201.from_port == 9201 && aws_security_group_rule.boundary_lb_allow_9201.to_port == 9201
    error_message = "Load balancer should allow inbound traffic on port 9201 from worker security group"
  }
}

run "lb_type_application" {
  assert {
    condition     = aws_lb.boundary_lb.load_balancer_type == "application"
    error_message = "Expected the load balancer type to be application"
  }
}

run "lb_public_subnets" {
  assert {
    condition = (
      length(aws_lb.boundary_lb.subnets) == length(var.public_subnet_ids) &&
      setintersection(aws_lb.boundary_lb.subnets, var.public_subnet_ids) == toset(var.public_subnet_ids)
    )
    error_message = "Load balancer subnets do not match the expected public subnet IDs"
  }
}

run "nlb_type_network" {
  assert {
    condition     = aws_lb.boundary_nlb.load_balancer_type == "network"
    error_message = "Expected the NLB type to be network"
  }
}

run "nlb_private_subnets" {
  assert {
    condition = (
      length(aws_lb.boundary_nlb.subnets) == length(var.private_subnet_ids) &&
      setintersection(aws_lb.boundary_nlb.subnets, var.private_subnet_ids) == toset(var.private_subnet_ids)
    )
    error_message = "NLB subnets do not match the expected private subnet IDs"
  }
}

run "route53_record" {
  assert {
    condition     = aws_route53_record.www[0].zone_id == var.aws_route53_zone && aws_route53_record.www[0].name == var.boundary_a_record
    error_message = "Route53 record should be created with correct zone and name"
  }
}

run "lb_target_group_controller" {
  assert {
    condition     = aws_lb_target_group.boundary_lb_controller.port == 9200 && aws_lb_target_group.boundary_lb_controller.protocol == "HTTPS"
    error_message = "Controller target group should use port 9200 and HTTPS protocol"
  }
}

run "lb_listener_controller" {
  assert {
    condition     = aws_lb_listener.boundary_lb_controller.port == 443 && aws_lb_listener.boundary_lb_controller.protocol == "HTTPS"
    error_message = "Controller listener should use port 443 and HTTPS protocol"
  }
}

run "lb_target_group_worker" {
  assert {
    condition     = aws_lb_target_group.boundary_lb_worker.port == 9201 && aws_lb_target_group.boundary_lb_worker.protocol == "TCP"
    error_message = "Worker target group should use port 9201 and TCP protocol"
  }
}

run "lb_listener_worker" {
  assert {
    condition     = aws_lb_listener.boundary_lb_worker.port == 9201 && aws_lb_listener.boundary_lb_worker.protocol == "TCP"
    error_message = "Worker listener should use port 9201 and TCP protocol"
  }
}

run "lb_listener_worker_nlb_association" {
  assert {
    condition     = aws_lb_listener.boundary_lb_worker.load_balancer_arn == aws_lb.boundary_nlb.arn
    error_message = "Worker listener should be associated with the NLB"
  }
}
