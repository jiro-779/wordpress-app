resource "aws_db_subnet_group" "wordpress" {
  name       = "${var.environment}-wp-db-subnet-group"
  subnet_ids = data.terraform_remote_state.platform.outputs.db_subnet_ids

  tags = {
    Name        = "${var.environment}-wp-db-subnet-group"
    Environment = var.environment
    Project     = "wordpress"
  }
}

resource "aws_db_parameter_group" "wordpress" {
  name   = "${var.environment}-wp-mysql-params"
  family = "mysql8.0"

  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }

  tags = {
    Name        = "${var.environment}-wp-mysql-params"
    Environment = var.environment
    Project     = "wordpress"
  }
}

resource "aws_db_instance" "wordpress" {
  identifier = "${var.environment}-wp-rds"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "wordpress"
  username = "wpadmin"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  parameter_group_name = aws_db_parameter_group.wordpress.name

  publicly_accessible = false
  multi_az            = var.db_multi_az

  storage_encrypted = true
  kms_key_id        = data.terraform_remote_state.platform.outputs.kms_key_arn

  skip_final_snapshot = true

  tags = {
    Name        = "${var.environment}-wp-rds"
    Environment = var.environment
    Project     = "wordpress"
  }
}