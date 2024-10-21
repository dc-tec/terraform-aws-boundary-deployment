resource "aws_vpc_endpoint" "ssm" {
  count = var.use_ssm ? 1 : 0

  vpc_id             = var.create_vpc == true ? aws_vpc.main[0].id : var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.create_vpc == true ? aws_subnet.private[*].id : var.private_subnet_ids
  security_group_ids = [aws_security_group.boundary_controller.id, aws_security_group.boundary_worker.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = var.use_ssm ? 1 : 0

  vpc_id             = var.create_vpc == true ? aws_vpc.main[0].id : var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.create_vpc == true ? aws_subnet.private[*].id : var.private_subnet_ids
  security_group_ids = [aws_security_group.boundary_controller.id, aws_security_group.boundary_worker.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = var.use_ssm ? 1 : 0

  vpc_id             = var.create_vpc == true ? aws_vpc.main[0].id : var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.create_vpc == true ? aws_subnet.private[*].id : var.private_subnet_ids
  security_group_ids = [aws_security_group.boundary_controller.id, aws_security_group.boundary_worker.id]
}
