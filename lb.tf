resource "aws_security_group" "boundary_lb" {
  vpc_id = var.vpc_id
  name   = "${var.name}-lb-sg"
}

resource "aws_security_group_rule" "boundary_lb_allow_9200" {
  description       = "Allow inbound traffic on port 9200 (TLS)"
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_lb.id
}

resource "aws_security_group_rule" "boundary_controller_lb_allow_outbound" {
  description       = "Allow outbound traffic"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_lb.id
}

resource "aws_lb" "boundary_lb" {
  name               = "${var.name}-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.boundary_lb.id]
  subnets            = var.public_subnet_ids
  idle_timeout       = 60

  tags = merge({ "Name" = "${var.name}-lb" }, var.tags)

}

resource "aws_route53_record" "www" {
  count = var.use_route53 ? 1 : 0

  zone_id = var.aws_route53_zone
  name    = var.boundary_a_record
  type    = "A"

  alias {
    name                   = aws_lb.boundary_lb.dns_name
    zone_id                = aws_lb.boundary_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_target_group" "boundary_lb" {
  name_prefix          = "ctrl-"
  port                 = 9200
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30
}

resource "aws_lb_listener" "boundary_lb" {
  load_balancer_arn = aws_lb.boundary_lb.arn
  port              = 9200
  protocol          = "TCP"

  certificate_arn = var.use_acm ? aws_acm_certificate.acm_boundary[0].arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.boundary_lb.arn
  }
}

resource "aws_security_group_rule" "boundary_lb_allow_9201" {
  description       = "Allow inbound traffic on port 9201 (TLS)"
  type              = "ingress"
  from_port         = 9201
  to_port           = 9201
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_lb.id
}

resource "aws_lb_target_group" "boundary_lb_worker" {
  name_prefix          = "wrkr-"
  port                 = 9201
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = 30
}

resource "aws_lb_listener" "boundary_lb_worker" {
  load_balancer_arn = aws_lb.boundary_lb.arn
  port              = 9201
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.boundary_lb_worker.arn
  }
}
