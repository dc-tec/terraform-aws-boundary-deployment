# Controller IAM
resource "aws_iam_role" "boundary_controller" {
  name = "${var.name}-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "boundary_controller" {
  name = "${var.name}-controller-profile"
  role = aws_iam_role.boundary_controller.name
}

resource "aws_iam_role_policy" "boundary" {
  name = "${var.name}-kms"
  role = aws_iam_role.boundary_controller.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListKeys",
      "kms:ListAliases"
    ],
    "Resource": [
      "${aws_kms_key.boundary_root.arn}",
      "${aws_kms_key.boundary_worker_auth.arn}",
      "${aws_kms_key.boundary_recovery.arn}"
    ]
  }
}
EOF
}

# Worker IAM
resource "aws_iam_role" "boundary_worker" {
  name = "${var.name}-worker"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "boundary_worker" {
  name = "${var.name}-worker-profile"
  role = aws_iam_role.boundary_worker.name
}

resource "aws_iam_role_policy" "boundary_worker" {
  name = "${var.name}-worker-kms"
  role = aws_iam_role.boundary_worker.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListKeys",
      "kms:ListAliases"
    ],
    "Resource": [
      "${aws_kms_key.boundary_worker_auth.arn}"
    ]
  }
}
EOF
}

# AWS Plugin Config
resource "aws_iam_user" "boundary" {
  name = "${var.name}-aws-plugin-user"
  path = "/"
}

resource "aws_iam_access_key" "boundary" {
  user = aws_iam_user.boundary.name
}

# TODO: Should make this more dynamic, and allow for more granular control over the resources
resource "aws_iam_user_policy" "boundary" {
  name   = "BoundaryDescribeInstances"
  user   = aws_iam_user.boundary.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# CloudWatch Config TODO:(check if we need to scope the permissions further on resource)
resource "aws_iam_role_policy" "cloudwatch_controller" {
  count = var.logging_enabled ? 1 : 0

  name = "${var.name}-controller-cloudwatch"
  role = aws_iam_role.boundary_controller.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ],
    "Resource": [
      "arn:aws:logs:*:*:*"
    ]
  }
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_worker" {
  count = var.logging_enabled ? 1 : 0

  name = "${var.name}-worker-cloudwatch"
  role = aws_iam_role.boundary_worker.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ],
    "Resource": [
      "arn:aws:logs:*:*:*"
    ]
  }
}
EOF
}
