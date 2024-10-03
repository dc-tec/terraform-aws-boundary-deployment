resource "aws_kms_key" "boundary_root" {
  description             = "Boundary root key"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "boundary_root" {
  name          = "alias/boundary_root"
  target_key_id = aws_kms_key.boundary_root.id
}

resource "aws_kms_key" "boundary_worker_auth" {
  description             = "Boundary worker authentication key"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "boundary_worker_auth" {
  name          = "alias/boundary_worker_auth"
  target_key_id = aws_kms_key.boundary_worker_auth.id
}

resource "aws_kms_key" "boundary_recovery" {
  description             = "Boundary recovery key"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "boundary_recovery" {
  name          = "alias/boundary_recovery"
  target_key_id = aws_kms_key.boundary_recovery.id
}
