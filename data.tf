data "aws_ami" "main" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_region" "current" {}

data "aws_iam_user" "boundary_admin" {
  for_each  = toset(var.boundary_admin_users)
  user_name = each.value
}
