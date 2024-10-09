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

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.controller_instance_volume_size
    }
  }


  iam_instance_profile {
    name = aws_iam_instance_profile.boundary_controller.name
  }

  user_data = base64encode(templatefile("${path.module}/templates/configure-controller.sh.tftpl", {
    DB_SECRET                 = aws_secretsmanager_secret.boundary_db_secret.name
    DB_USERNAME               = var.db_username
    DB_PASSWORD               = random_password.boundary_db_password.result
    DB_ENDPOINT               = aws_db_instance.boundary_db.endpoint
    DB_NAME                   = aws_db_instance.boundary_db.db_name
    KMS_WORKER_AUTH_KEY_ID    = aws_kms_key.boundary_worker_auth.id
    KMS_RECOVERY_KEY_ID       = aws_kms_key.boundary_recovery.id
    KMS_ROOT_KEY_ID           = aws_kms_key.boundary_root.id
    API_CERT_KEY              = aws_secretsmanager_secret.boundary_api_cert_key.name
    API_CERT                  = aws_secretsmanager_secret.boundary_api_cert.name
    LOGGING_ENABLED           = var.logging_enabled
    LOGGING_RETENTION_IN_DAYS = var.logging_retention_in_days
    USE_CLOUDWATCH            = var.use_cloudwatch
    CLOUDWATCH_LOG_GROUP      = var.use_cloudwatch ? aws_cloudwatch_log_group.boundary_controller[0].name : ""
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}

resource "aws_autoscaling_group" "boundary_controller" {
  name             = "${var.name}-controller-asg"
  min_size         = var.boundary_controller_asg.min_size
  max_size         = var.boundary_controller_asg.max_size
  desired_capacity = var.boundary_controller_asg.desired_capacity

  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns = [
    aws_lb_target_group.boundary_lb_controller.arn,
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

resource "aws_cloudwatch_log_group" "boundary_controller" {
  count = var.use_cloudwatch ? 1 : 0

  name              = "/aws/ec2/${var.name}-controller"
  retention_in_days = var.logging_retention_in_days
  tags              = var.tags
}
