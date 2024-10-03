output "boundary_worker_auth_key" {
  value     = aws_kms_key.boundary_worker_auth.id
  sensitive = true
}

output "boundary_lb_dns" {
  value = aws_lb.boundary_lb.dns_name
}

output "boundary_worker_sg_id" {
  value = aws_security_group.boundary_worker.id
}

output "boundary_aws_plugin_access_key_id" {
  value = aws_iam_access_key.boundary.id
}

output "boundary_aws_plugin_secret_access_key" {
  value     = aws_iam_access_key.boundary.secret
  sensitive = true
}
