variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "allowed_ssh_inbound_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks to allow SSH access to the Controllers and Workers"

  default = ["0.0.0.0/0"]
}

variable "enable_ssh" {
  type        = bool
  description = "Whether to enable SSH access to the Controllers and Workers"

  default = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
}

variable "name" {
  type        = string
  description = "The name of the deployment"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "db_instance_class" {
  type        = string
  description = "The instance class to use for the Boundary Database"

  default = "db.t3.micro"
}

variable "db_username" {
  type        = string
  description = "The username to use for the Boundary Database user"

  default = "postgres"
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
}

variable "worker_instance_type" {
  type        = string
  description = "The instance type to use for the Boundary Workers"

  default = "t3.micro"
}

variable "boundary_a_record" {
  type        = string
  description = "The A record to create in Route 53 for the Boundary Controller"

  default = "boundary.example.com"
}

variable "aws_route53_zone" {
  type        = string
  description = "The Route 53 zone to create the A record in"
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

variable "logging_types" {
  type        = map(bool)
  description = "The types of logs to enable for the Boundary Controller"

  default = {
    "audit"       = true,
    "observation" = true,
    "sysevents"   = true,
    "telemetry"   = true
  }
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
}

variable "boundary_worker_asg" {
  type = object({
    min_size         = number
    max_size         = number
    desired_capacity = number
  })
  description = "The configuration for the Boundary Controller Auto Scaling Group"

  default = {
    min_size         = 1
    max_size         = 10
    desired_capacity = 1
  }
}
