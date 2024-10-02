variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "allowed_inbound_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks to allow SSH access to the Controllers and Workers"
}

variable "enable_ssh" {
  type        = bool
  description = "Whether to enable SSH access to the Controllers and Workers"

  default = false
}

variable "controller_count" {
  type        = number
  description = "The number of Boundary Controllers to deploy"

  default = 3
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "List of public subnet CIDR blocks"
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

variable "db_username" {
  type        = string
  description = "The username to use for the Boundary Database user"

  default = "postgres"
}

variable "ssh_public_key" {
  type        = string
  description = "The public key to use for SSH access"
}

variable "boundary_a_record" {
  type        = string
  description = "The A record to create in Route 53 for the Boundary Controller"

  default = "boundary.adfinis.dev"
}

variable "aws_route53_zone" {
  type        = string
  description = "The Route 53 zone to create the A record in"
}
