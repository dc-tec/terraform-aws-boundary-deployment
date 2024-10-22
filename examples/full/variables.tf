variable "name" {
  description = "The name of the boundary deployment"
  type        = string
}

variable "create_vpc" {
  description = "Whether to create a VPC"
  type        = bool
  default     = true
}

variable "use_acm" {
  description = "Whether to use ACM for the boundary service"
  type        = bool
  default     = true
}

variable "use_ssm" {
  description = "Whether to use SSM for the boundary service"
  type        = bool
  default     = true
}

variable "use_route53" {
  description = "Whether to use Route53 for the boundary service"
  type        = bool
  default     = true
}


variable "use_cloudwatch" {
  description = "Whether to use CloudWatch for the boundary service"
  type        = bool
  default     = true
}

variable "controller_deployment_type" {
  description = "The deployment type to use for the Boundary Controller"
  type        = string
  default     = "development"
}

variable "worker_deployment_type" {
  description = "The deployment type to use for the Boundary Worker"
  type        = string
  default     = "development"
}

variable "boundary_a_record" {
  description = "The A record to use for the boundary service"
  type        = string
}

variable "aws_route53_zone" {
  description = "The AWS Route53 zone to use for the boundary service"
  type        = string
}

variable "tags" {
  description = "The tags to use for the boundary deployment"
  type        = map(string)
}

variable "logging_enabled" {
  description = "Whether to enable logging for the boundary deployment"
  type        = bool
  default     = true
}

variable "boundary_admin_users" {
  description = "The admin users for the boundary deployment"
  type        = list(string)
}
