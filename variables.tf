# General configuration
variable "name" {
  type        = string
  description = "The name of the deployment"

  default = "boundary"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "The name must only contain alphanumeric characters and hyphens."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"

  default = {
    "Project"     = "Boundary"
    "Environment" = "Development"
  }
}

# Network configuration
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"

  default = "vpc-0123456789abcdefg"

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id must start with 'vpc-'."
  }
}

variable "create_vpc" {
  type        = bool
  description = "Whether to create a new VPC"

  default = true

  validation {
    condition     = var.vpc_id == "vpc-0123456789abcdefg" ? var.create_vpc : !var.create_vpc
    error_message = "The vpc_id and create_vpc variables must be mutually exclusive and var.vpc_id must be a valid VPC ID."
  }
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"

  default = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "The vpc_cidr_block must be a valid CIDR block."
  }
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"

  default = ["subnet-0123456789abcdefg", "subnet-0123456789abcdefg"]

  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "At least one private subnet ID must be provided."
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"

  default = ["subnet-0123456789abcdefg", "subnet-0123456789abcdefg"]

  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "At least one public subnet ID must be provided."
  }
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"

  default = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = can([for cidr in var.private_subnet_cidr_blocks : cidrhost(cidr, 0)])
    error_message = "All elements in private_subnet_cidr_blocks must be valid CIDR blocks."
  }
}

variable "public_subnet_count" {
  type        = number
  description = "The number of public subnets to create"

  default = 3
}

variable "private_subnet_count" {
  type        = number
  description = "The number of private subnets to create"

  default = 3
}

# Database configuration
variable "db_instance_class" {
  type        = string
  description = "The instance class to use for the Boundary Database"

  default = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.", var.db_instance_class))
    error_message = "The db_instance_class must start with 'db.'."
  }
}

variable "db_engine_version" {
  type        = string
  description = "The engine version to use for the Boundary Database (must be version 13.0 or higher)"

  default = "16.4"

  validation {
    condition = (
      can(regex("^[0-9]+\\.[0-9]+$", var.db_engine_version)) &&
      tonumber(split(".", var.db_engine_version)[0]) >= 13
    )
    error_message = "The db_engine_version must be a valid PostgreSQL engine version 13.0 or higher."
  }
}

variable "db_allocated_storage" {
  type        = number
  description = "The amount of storage to allocate for the Boundary Database"

  default = 20

  validation {
    condition     = var.db_allocated_storage >= 20
    error_message = "The db_allocated_storage must be at least 20GB."
  }
}

variable "db_backup_enabled" {
  type        = bool
  description = "Whether to enable backups for the Boundary Database"

  default = true
}

variable "db_backup_window" {
  type        = string
  description = "The backup window for the Boundary Database"

  default = "03:00-06:00"
}

variable "db_backup_retention_period" {
  type        = number
  description = "The number of days to retain backups for"

  default = 7

  validation {
    condition     = var.db_backup_retention_period >= 7 && var.db_backup_retention_period <= 35
    error_message = "The db_backup_retention_period must be between 7 and 35 days."
  }
}

variable "db_multi_az" {
  type        = bool
  description = "Whether to enable Multi-AZ for the Boundary Database"

  default = false
}


variable "db_username" {
  type        = string
  description = "The username to use for the Boundary Database user"

  default = "postgres"

  validation {
    condition     = length(var.db_username) >= 1 && length(var.db_username) <= 63
    error_message = "The db_username must be between 1 and 63 characters long."
  }
}

# Instance configuration
variable "controller_deployment_type" {
  type        = string
  description = "The deployment type to use for the Boundary Controller"

  default = "development"

  validation {
    condition     = contains(["development", "small", "large"], var.controller_deployment_type)
    error_message = "The controller deployment type must be one of 'development', 'small', or 'large'."
  }
}

variable "worker_deployment_type" {
  type        = string
  description = "The deployment type to use for the Boundary Worker"

  default = "development"

  validation {
    condition     = contains(["development", "small", "large"], var.worker_deployment_type)
    error_message = "The worker deployment type must be one of 'development', 'small', or 'large'."
  }
}

# Auto Scaling Group configuration
variable "boundary_controller_asg" {
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
    default_cooldown = number
    instance_warmup  = number
  })

  description = "The configuration for the Boundary Controller Auto Scaling Group"

  default = {
    min_size         = 3
    max_size         = 6
    desired_capacity = 3
    default_cooldown = 300
    instance_warmup  = 300
  }

  validation {
    condition     = var.boundary_controller_asg.min_size <= var.boundary_controller_asg.desired_capacity && var.boundary_controller_asg.desired_capacity <= var.boundary_controller_asg.max_size
    error_message = "The desired_capacity must be between min_size and max_size for the Boundary Controller ASG."
  }
}

variable "boundary_worker_asg" {
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
    default_cooldown = number
    instance_warmup  = number
  })
  description = "The configuration for the Boundary Worker Auto Scaling Group"

  default = {
    min_size         = 1
    max_size         = 10
    desired_capacity = 1
    default_cooldown = 300
    instance_warmup  = 300
  }

  validation {
    condition     = var.boundary_worker_asg.min_size <= var.boundary_worker_asg.desired_capacity && var.boundary_worker_asg.desired_capacity <= var.boundary_worker_asg.max_size
    error_message = "The desired_capacity must be between min_size and max_size for the Boundary Worker ASG."
  }
}

# DNS and TLS configuration
variable "use_route53" {
  type        = bool
  description = "Use Route53 to create a DNS record"

  default = false
}

variable "aws_route53_zone" {
  type        = string
  description = "The Route 53 zone to create the A record in"

  default = "Z12345678901234567890"

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.aws_route53_zone))
    error_message = "The aws_route53_zone must be a valid Route 53 zone ID."
  }
}

variable "boundary_a_record" {
  type        = string
  description = "The A record to create in Route 53 for the Boundary Controller"

  default = "boundary.example.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+$", var.boundary_a_record))
    error_message = "The boundary_a_record must be a valid domain name."
  }
}

variable "use_acm" {
  type        = bool
  description = "Whether to use ACM to generate a certificate or generate a self-signed certificate for the Boundary Controller"

  default = false
}

# Logging and monitoring configuration
variable "logging_enabled" {
  type        = bool
  description = "Whether to enable logging for the Boundary Controller"

  default = false
}

variable "use_cloudwatch" {
  type        = bool
  description = "Whether to use AWS CloudWatch to log the Boundary Controller"

  default = false
}

variable "logging_retention_in_days" {
  type        = number
  description = "The number of days to retain logs for"

  default = 30

  validation {
    condition     = var.logging_retention_in_days > 0 && var.logging_retention_in_days <= 3653
    error_message = "The logging_retention_in_days must be between 1 and 3653."
  }
}

# Security and access configuration
variable "use_ssm" {
  type        = bool
  description = "Whether to use AWS SSM to access the Boundary Controllers and Workers"

  default = false
}

variable "enable_ssh" {
  type        = bool
  description = "Whether to enable SSH access to the Controllers and Workers"

  default = false
}

variable "allowed_ssh_inbound_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks to allow SSH access to the Controllers and Workers"

  default = ["0.0.0.0/0"]

  validation {
    condition     = can([for cidr in var.allowed_ssh_inbound_cidr_blocks : cidrhost(cidr, 0)])
    error_message = "All elements in allowed_ssh_inbound_cidr_blocks must be valid CIDR blocks."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for SSH access"

  default = null
}

variable "boundary_admin_users" {
  type        = list(string)
  description = "The list of Boundary admin users"

  default = ["boundary-admin"]
}
