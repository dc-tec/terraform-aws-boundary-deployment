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

resource "aws_iam_user" "boundary" {
  name = "${var.name}-aws-plugin-user"
  path = "/"
}

resource "aws_iam_access_key" "boundary" {
  user = aws_iam_user.boundary.name
}

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
