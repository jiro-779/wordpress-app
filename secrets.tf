resource "random_password" "db" {
  length           = 20
  special          = true
  override_special = "_%@-"
}

resource "aws_secretsmanager_secret" "db" {
  name       = "${var.environment}-wp-db-credentials"
  kms_key_id = data.terraform_remote_state.platform.outputs.kms_key_arn

  tags = {
    Name        = "${var.environment}-wp-db-credentials"
    Environment = var.environment
    Project     = "wordpress"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "wpadmin"
    password = random_password.db.result
  })
}