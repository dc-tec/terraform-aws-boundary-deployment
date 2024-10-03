resource "aws_security_group" "boundary_controller" {
  vpc_id = var.vpc_id
  name   = "${var.name}-controller-sg"
  tags   = var.tags
}

resource "aws_security_group_rule" "boundary_controller_allow_9200_lb" {
  type                     = "ingress"
  from_port                = 9200
  to_port                  = 9200
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_lb.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "boundary_controller_api_self" {
  type      = "ingress"
  from_port = 9200
  to_port   = 9200
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "boundary_controller_health_allow_9203" {
  type                     = "ingress"
  from_port                = 9203
  to_port                  = 9203
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_lb.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_9201_boundary_workers_direct" {
  type                     = "ingress"
  from_port                = 9201
  to_port                  = 9201
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_worker.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_9201_boundary_workers" {
  type                     = "ingress"
  from_port                = 9201
  to_port                  = 9201
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.boundary_lb.id
  security_group_id        = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_ssh_boundary_controller" {
  count             = var.enable_ssh ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_inbound_cidr_blocks
  security_group_id = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_egress_boundary_controller" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_controller.id
}

resource "aws_launch_template" "boundary_controller" {
  name                   = "${var.name}-controller-lt"
  image_id               = data.aws_ami.main.id
  instance_type          = var.controller_instance_type
  key_name               = var.ssh_public_key
  vpc_security_group_ids = [aws_security_group.boundary_controller.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.boundary_controller.name
  }

  user_data = base64encode(templatefile("./templates/configure-controller.sh", {
    DB_USERNAME            = var.db_username
    DB_PASSWORD            = random_password.boundary_db_password.result
    DB_ENDPOINT            = aws_db_instance.boundary_db.endpoint
    DB_NAME                = aws_db_instance.boundary_db.db_name
    KMS_WORKER_AUTH_KEY_ID = aws_kms_key.boundary_worker_auth.id
    KMS_RECOVERY_KEY_ID    = aws_kms_key.boundary_recovery.id
    KMS_ROOT_KEY_ID        = aws_kms_key.boundary_root.id
    SERVER_KEY             = var.use_acm ? aws_acm_certificate.acm_boundary[0].private_key : tls_private_key.boundary_key[0].private_key_pem
    SERVER_CERT            = var.use_acm ? aws_acm_certificate.acm_boundary[0].certificate_chain : tls_self_signed_cert.boundary_cert[0].cert_pem
    LOGGING_ENABLED        = var.logging_enabled
    AUDIT_ENABLED          = var.logging_types.audit
    OBSERVERVATION_ENABLED = var.logging_types.observation
    SYSEVENTS_ENABLED      = var.logging_types.sysevents
    TELEMETRY_ENABLED      = var.logging_types.telemetry
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }
}

resource "aws_autoscaling_group" "boundary_controller" {
  name             = "${var.name}-controller-asg"
  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns = [
    aws_lb_target_group.boundary_lb.arn,
    aws_lb_target_group.boundary_lb_worker.arn
  ]

  launch_template {
    id      = aws_launch_template.boundary_controller.id
    version = "$Latest"
  }

  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-controller-asg"
    propagate_at_launch = true
  }
}
