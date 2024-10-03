resource "aws_acm_certificate" "acm_boundary" {
  count = var.use_acm ? 1 : 0

  domain_name       = var.boundary_a_record
  validation_method = "DNS"
  tags              = merge({ "Name" = "${var.boundary_a_record}" }, var.tags)
}

resource "aws_route53_record" "acm_dns_validation" {
  for_each = var.use_acm ? {} : {
    for dvo in aws_acm_certificate.acm_boundary[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = var.aws_route53_zone
}

resource "aws_acm_certificate_validation" "acm_validation" {
  count = var.use_acm ? 1 : 0

  certificate_arn         = aws_acm_certificate.acm_boundary[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_dns_validation : record.fqdn]
}

resource "tls_private_key" "boundary_key" {
  count = var.use_acm ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "boundary_cert" {
  count = var.use_acm ? 0 : 1

  private_key_pem   = tls_private_key.boundary_key[0].private_key_pem
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
