variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id must start with 'vpc-'."
  }
}

variable "allowed_ssh_inbound_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks to allow SSH access to the Controllers and Workers"

  default = ["0.0.0.0/0"]

  validation {
    condition     = can([for cidr in var.allowed_ssh_inbound_cidr_blocks : cidr_block(cidr)])
    error_message = "All elements in allowed_ssh_inbound_cidr_blocks must be valid CIDR blocks."
  }
}

variable "enable_ssh" {
  type        = bool
  description = "Whether to enable SSH access to the Controllers and Workers"

  default = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"

  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "At least one private subnet ID must be provided."
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"

  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "At least one public subnet ID must be provided."
  }
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"

  validation {
    condition     = can([for cidr in var.private_subnet_cidr_blocks : cidr_block(cidr)])
    error_message = "All elements in private_subnet_cidr_blocks must be valid CIDR blocks."
  }
}

variable "name" {
  type        = string
  description = "The name of the deployment"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "The name must only contain alphanumeric characters and hyphens."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "db_instance_class" {
  type        = string
  description = "The instance class to use for the Boundary Database"

  default = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.", var.db_instance_class))
    error_message = "The db_instance_class must start with 'db.'."
  }
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

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for SSH access"

  default = null
}

variable "controller_instance_type" {
  type        = string
  description = "The instance type to use for the Boundary Controller"
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][1-9][.][a-z0-9]+$", var.controller_instance_type))
    error_message = "The controller_instance_type must be a valid EC2 instance type."
  }
}

variable "worker_instance_type" {
  type        = string
  description = "The instance type to use for the Boundary Workers"

  default = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][1-9][.][a-z0-9]+$", var.worker_instance_type))
    error_message = "The worker_instance_type must be a valid EC2 instance type."
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

variable "aws_route53_zone" {
  type        = string
  description = "The Route 53 zone to create the A record in"

  validation {
    condition     = can(regex("^Z[A-Z0-9]+$", var.aws_route53_zone))
    error_message = "The aws_route53_zone must be a valid Route 53 zone ID."
  }
}

variable "use_route53" {
  type        = bool
  description = "Use Route53 to create a DNS record"

  default = true
}

variable "use_acm" {
  type        = bool
  description = "Whether to use ACM to generate a certificate or generate a self-signed certificate for the Boundary Controller"

  default = true
}

variable "logging_enabled" {
  type        = bool
  description = "Whether to enable logging for the Boundary Controller"

  default = false
}

variable "boundary_controller_asg" {
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
  description = "The configuration for the Boundary Controller Auto Scaling Group"

  default = {
    min_size         = 3
    max_size         = 6
    desired_capacity = 3
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
  })
  description = "The configuration for the Boundary Worker Auto Scaling Group"

  default = {
    min_size         = 1
    max_size         = 10
    desired_capacity = 1
  }

  validation {
    condition     = var.boundary_worker_asg.min_size <= var.boundary_worker_asg.desired_capacity && var.boundary_worker_asg.desired_capacity <= var.boundary_worker_asg.max_size
    error_message = "The desired_capacity must be between min_size and max_size for the Boundary Worker ASG."
  }
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
