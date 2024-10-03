resource "random_password" "boundary_db_password" {
  length           = 32
  special          = true
  override_special = "!#%&()*+,-.:;<=>?[]^_{|}~"
}

resource "aws_db_subnet_group" "boundary_db" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge({ "Name" = "${var.name}-db-subnet-group" }, var.tags)
}

resource "aws_security_group" "boundary_db" {
  vpc_id = var.vpc_id
  name   = "${var.name}-db-sg"
}

resource "aws_security_group_rule" "boundary_controller_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.boundary_db.id
  source_security_group_id = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_egress_boundary_db" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.private_subnet_cidr_blocks
  security_group_id = aws_security_group.boundary_db.id
}

resource "aws_db_instance" "boundary_db" {
  identifier = "${var.name}-db"

  engine         = "postgres"
  engine_version = "16.4"

  instance_class    = var.db_instance_class
  db_name           = "boundary"
  allocated_storage = 20

  username = var.db_username
  password = random_password.boundary_db_password.result

  db_subnet_group_name   = aws_db_subnet_group.boundary_db.name
  vpc_security_group_ids = [aws_security_group.boundary_db.id]
  skip_final_snapshot    = true
  storage_type           = "gp2"

  tags = merge({ "Name" = "${var.name}-db" }, var.tags)
}
