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
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-west-2a", "us-west-2b", "us-west-2c"]
    }
  }
}

variables {
  name = "boundary"
  tags = {
    "Terraform-Test" = "true"
  }
  create_vpc           = true
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_count  = 2
  private_subnet_count = 2
}

run "vpc_creation" {
  assert {
    condition = (
      length(aws_vpc.main) == 1 &&
      aws_vpc.main[0].cidr_block == var.vpc_cidr &&
      aws_vpc.main[0].enable_dns_hostnames == true &&
      aws_vpc.main[0].enable_dns_support == true
    )
    error_message = "VPC should be created with correct configuration when create_vpc is true"
  }
}

run "subnet_creation" {
  assert {
    condition = (
      length(aws_subnet.public) == var.public_subnet_count &&
      length(aws_subnet.private) == var.private_subnet_count
    )
    error_message = "Public and private subnets should be created with correct count"
  }
}

run "internet_gateway" {
  assert {
    condition     = length(aws_internet_gateway.main) == 1
    error_message = "Internet Gateway should be created"
  }
}

run "nat_gateway" {
  assert {
    condition     = length(aws_nat_gateway.main) == var.public_subnet_count
    error_message = "NAT Gateways should be created for each public subnet"
  }
}

run "route_tables" {
  assert {
    condition = (
      length(aws_route_table.public) == 1 &&
      length(aws_route_table.private) == var.private_subnet_count
    )
    error_message = "Route tables should be created for public and private subnets"
  }
}
