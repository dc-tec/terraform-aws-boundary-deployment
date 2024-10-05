output "boundary_worker_auth_key" {
  description = "Boundary Worker Authentication Key, used for initializition of Boundary"

  value     = aws_kms_key.boundary_worker_auth.id
  sensitive = true
}

output "boundary_lb_dns" {
  description = "DNS address of the Load Balancer, if chosen to opt out of route53 usage"

  value = aws_lb.boundary_lb.dns_name
}

output "boundary_worker_sg_id" {
  description = "Boundary Worker Security Group ID"

  value = aws_security_group.boundary_worker.id
}

output "boundary_aws_plugin_access_key_id" {
  description = "Boundary AWS Plugin Access Key ID"
  value       = aws_iam_access_key.boundary.id
}

output "boundary_aws_plugin_secret_access_key" {
  description = "Boundary AWS Plugin Secret Access Key"

  value     = aws_iam_access_key.boundary.secret
  sensitive = true
}
