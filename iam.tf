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

resource "aws_iam_role_policy" "boundary_controller_secretsmanager" {
  name = "${var.name}-controller-secretsmanager"
  role = aws_iam_role.boundary_controller.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "secretsmanager:GetSecretValue"
    ],
    "Resource": [
      "${aws_secretsmanager_secret.boundary_api_cert.arn}",
      "${aws_secretsmanager_secret.boundary_api_cert_key.arn}",
      "${aws_secretsmanager_secret.boundary_db_secret.arn}"
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

# CloudWatch Config TODO:(check if we need to scope the actions for these permissions further)
resource "aws_iam_role_policy" "cloudwatch_controller" {
  count = var.use_cloudwatch ? 1 : 0

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
  count = var.use_cloudwatch ? 1 : 0

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

# SSM Config
resource "aws_iam_role_policy" "ssm_controller" {
  count = var.use_ssm ? 1 : 0

  name = "${var.name}-controller-ssm"
  role = aws_iam_role.boundary_controller.name

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": [
        "*"
      ]
    }
  }
EOF
}

resource "aws_iam_role_policy" "ssm_worker" {
  count = var.use_ssm ? 1 : 0

  name = "${var.name}-worker-ssm"
  role = aws_iam_role.boundary_worker.name

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": [
        "*"
      ]
    }
  }
EOF
}

resource "aws_iam_group" "boundary_admin" {
  name = "${var.name}-boundary-admin"
}

resource "aws_iam_group_membership" "boundary_admin" {
  name  = "${var.name}-boundary-admin"
  group = aws_iam_group.boundary_admin.name
  users = [for user in var.boundary_admin_users : data.aws_iam_user.boundary_admin[user].user_name]
}

resource "aws_iam_group_policy" "boundary_admin" {
  count = var.use_ssm ? 1 : 0

  name  = "${var.name}-boundary-admin-ssm"
  group = aws_iam_group.boundary_admin.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceProperties",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:TerminateSession",
          "ssm:ResumeSession"
        ]
        Resource = "arn:aws:ssm:*:*:session/$${aws:username}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups"
        ]
        Resource = [
          aws_autoscaling_group.boundary_controller.arn,
          aws_autoscaling_group.boundary_worker.arn
        ]
      }
    ]
  })
}
