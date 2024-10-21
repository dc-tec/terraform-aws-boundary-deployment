locals {
  public_subnets = [for network in range(var.public_subnet_count) : cidrsubnet(var.vpc_cidr_block, 3, network)]

  private_subnets = [for network in range(var.private_subnet_count) : cidrsubnet(var.vpc_cidr_block, 3, network + var.public_subnet_count)] ## We skip the already configured public subnets so we dont get errors that a network is already configured

  controllers_sizing = {
    "development" = {
      instance_type = "t3.micro"
      volume_size   = 50
    }
    "small" = {
      instance_type = "m5.large"
      volume_size   = 50
    }
    "large" = {
      instance_type = "m5.2xlarge"
      volume_size   = 100
    }
  }

  workers_sizing = {
    "development" = {
      instance_type = "t3.micro"
      volume_size   = 50
    }
    "small" = {
      instance_type = "m5.large"
      volume_size   = 50
    }
    "large" = {
      instance_type = "m5.2xlarge"
      volume_size   = 100
    }
  }
}
