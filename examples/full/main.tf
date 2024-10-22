terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  required_version = "~> 1.9"

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {}

data "aws_route53_zone" "main" {
  name = var.aws_route53_zone
}

module "boundary" {
  #source  = "dc-tec/terraform-aws-boundary-deployment"
  #version = "~> 1.0"

  source = "../../"

  name                 = var.name
  create_vpc           = var.create_vpc
  aws_route53_zone     = data.aws_route53_zone.main.zone_id
  boundary_a_record    = var.boundary_a_record
  use_acm              = var.use_acm
  use_ssm              = var.use_ssm
  use_route53          = var.use_route53
  use_cloudwatch       = var.use_cloudwatch
  logging_enabled      = var.logging_enabled
  boundary_admin_users = var.boundary_admin_users

  controller_deployment_type = var.controller_deployment_type
  worker_deployment_type     = var.worker_deployment_type

  tags = var.tags
}
