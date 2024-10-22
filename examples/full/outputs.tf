output "boundary_worker_auth_key" {
  description = "Boundary Worker Authentication Key, used for initialization of Boundary"
  value       = module.boundary.boundary_worker_auth_key
  sensitive   = true
}

output "boundary_endpoint" {
  description = "DNS address of the Load Balancer for accessing Boundary"
  value       = module.boundary.boundary_lb_dns
}

output "boundary_worker_security_group_id" {
  description = "Boundary Worker Security Group ID"
  value       = module.boundary.boundary_worker_sg_id
}

output "boundary_aws_plugin_access_key_id" {
  description = "Boundary AWS Plugin Access Key ID"
  value       = module.boundary.boundary_aws_plugin_access_key_id
}

output "boundary_aws_plugin_secret_access_key" {
  description = "Boundary AWS Plugin Secret Access Key"
  value       = module.boundary.boundary_aws_plugin_secret_access_key
  sensitive   = true
}
