resource "aws_acm_certificate" "acm_boundary" {
  count = var.use_acm ? 1 : 0

  domain_name       = var.boundary_a_record
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ "Name" = "${var.boundary_a_record}" }, var.tags)
}

resource "aws_route53_record" "acm_dns_validation" {
  for_each = var.use_acm ? {
    for dvo in aws_acm_certificate.acm_boundary[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.aws_route53_zone
}

resource "aws_acm_certificate_validation" "acm_validation" {
  count = var.use_acm ? 1 : 0

  certificate_arn         = aws_acm_certificate.acm_boundary[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_dns_validation : record.fqdn]
}

resource "tls_private_key" "boundary_api_cert_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "boundary_api_cert" {
  private_key_pem   = tls_private_key.boundary_api_cert_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name = var.boundary_a_record
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "boundary_api_cert" {
  private_key      = tls_private_key.boundary_api_cert_key.private_key_pem
  certificate_body = tls_self_signed_cert.boundary_api_cert.cert_pem

  tags = merge({ "Name" = "${var.boundary_a_record}-api-cert" }, var.tags)
}

resource "aws_secretsmanager_secret" "boundary_api_cert_key" {
  name = "${var.name}-api-cert-key"

  tags = merge({ "Name" = "${var.name}-api-cert-key" }, var.tags)
}

resource "aws_secretsmanager_secret_version" "boundary_self_signed_key" {
  secret_id     = aws_secretsmanager_secret.boundary_api_cert_key.id
  secret_string = tls_private_key.boundary_api_cert_key.private_key_pem
}

resource "aws_secretsmanager_secret" "boundary_api_cert" {
  name = "${var.name}-api-cert"

  tags = merge({ "Name" = "${var.name}-api-cert" }, var.tags)
}

resource "aws_secretsmanager_secret_version" "boundary_api_cert" {
  secret_id     = aws_secretsmanager_secret.boundary_api_cert.id
  secret_string = tls_self_signed_cert.boundary_api_cert.cert_pem
}
