resource "random_password" "boundary_db_password" {
  length           = 32
  special          = true
  override_special = "!#%&()*+,-.:;<=>?[]^_{|}~"
}

resource "aws_db_subnet_group" "boundary_db" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.create_vpc == true ? aws_subnet.private[*].id : var.private_subnet_ids

  tags = merge({ "Name" = "${var.name}-db-subnet-group" }, var.tags)
}

resource "aws_security_group" "boundary_db" {
  vpc_id = var.create_vpc == true ? aws_vpc.main[0].id : var.vpc_id
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
  cidr_blocks       = var.create_vpc == true ? local.private_subnets : var.private_subnet_cidr_blocks
  security_group_id = aws_security_group.boundary_db.id
}

resource "aws_secretsmanager_secret" "boundary_db_secret" {
  name = "${var.name}-db-secret"

  tags = merge({ "Name" = "${var.name}-db-secret" }, var.tags)
}

resource "aws_secretsmanager_secret_version" "boundary_db_secret" {
  secret_id = aws_secretsmanager_secret.boundary_db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.boundary_db_password.result
    endpoint = aws_db_instance.boundary_db.endpoint
    dbname   = aws_db_instance.boundary_db.db_name
  })
}

resource "aws_db_instance" "boundary_db" {
  identifier = "${var.name}-db"

  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class    = var.db_instance_class
  db_name           = "boundary"
  allocated_storage = var.db_allocated_storage

  backup_window           = var.db_backup_enabled ? var.db_backup_window : null
  backup_retention_period = var.db_backup_enabled ? var.db_backup_retention_period : null

  multi_az = var.db_multi_az

  blue_green_update {
    enabled = true
  }

  username = var.db_username
  password = random_password.boundary_db_password.result

  db_subnet_group_name   = aws_db_subnet_group.boundary_db.name
  vpc_security_group_ids = [aws_security_group.boundary_db.id]

  skip_final_snapshot = true
  storage_type        = "gp2"

  tags = merge({ "Name" = "${var.name}-db" }, var.tags)
}
