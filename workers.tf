resource "aws_security_group" "boundary_worker" {
  vpc_id = var.vpc_id
  name   = "${var.name}-worker-sg"

  tags = var.tags
}

resource "aws_security_group_rule" "boundary_worker_allow_9202_self" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "boundary_worker_allow_9202_users" {
  type              = "ingress"
  from_port         = 9202
  to_port           = 9202
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "allow_ssh_boundary_worker" {
  count = var.enable_ssh ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ssh_inbound_cidr_blocks
  security_group_id = aws_security_group.boundary_worker.id
}

resource "aws_security_group_rule" "boundary_worker_allow_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_worker.id
}

resource "aws_launch_template" "boundary_worker" {
  name                   = "${var.name}-worker-lt"
  image_id               = data.aws_ami.main.id
  instance_type          = var.worker_instance_type
  key_name               = var.ssh_public_key
  vpc_security_group_ids = [aws_security_group.boundary_worker.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.boundary_worker.name
  }

  user_data = base64encode(templatefile("${path.module}/templates/configure-worker.sh", {
    KMS_WORKER_AUTH_KEY_ID = aws_kms_key.boundary_worker_auth.id
    BOUNDARY_LB_DNS_NAME   = aws_lb.boundary_lb.dns_name
    LOGGING_ENABLED        = var.logging_enabled
    CLOUDWATCH_LOG_GROUP   = var.logging_enabled ? aws_cloudwatch_log_group.boundary_worker[0].name : ""
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }
}

resource "aws_autoscaling_group" "boundary_worker" {
  name             = "${var.name}-worker-asg"
  min_size         = var.boundary_worker_asg.min_size
  max_size         = var.boundary_worker_asg.max_size
  desired_capacity = var.boundary_worker_asg.desired_capacity

  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.boundary_worker.id
    version = "$Latest"
  }

  health_check_type = "ELB"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-worker-asg"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_log_group" "boundary_worker" {
  count = var.logging_enabled ? 1 : 0

  name              = "/aws/ec2/${var.name}-worker"
  retention_in_days = var.logging_retention_in_days
  tags              = var.tags
}
