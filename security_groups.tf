resource "aws_security_group" "alb" {
  name        = "${var.environment}-wp-alb-sg"
  description = "Security group for WordPress ALB"
  vpc_id      = data.terraform_remote_state.platform.outputs.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-wp-alb-sg"
    Environment = var.environment
    Project     = "wordpress"
  }
}
resource "aws_security_group" "ec2" {
  name        = "${var.environment}-wp-ec2-sg"
  description = "Security group for WordPress EC2 instances"
  vpc_id      = data.terraform_remote_state.platform.outputs.vpc_id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-wp-ec2-sg"
    Environment = var.environment
    Project     = "wordpress"
  }
}
resource "aws_security_group" "efs" {
  name        = "${var.environment}-wp-efs-sg"
  description = "Security group for EFS"
  vpc_id      = data.terraform_remote_state.platform.outputs.vpc_id

  ingress {
    description     = "NFS from EC2 only"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-wp-efs-sg"
    Environment = var.environment
    Project     = "wordpress"
  }
}
resource "aws_security_group" "rds" {
  name        = "${var.environment}-wp-rds-sg"
  description = "Security group for RDS"
  vpc_id      = data.terraform_remote_state.platform.outputs.vpc_id

  ingress {
    description     = "MySQL from EC2 only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-wp-rds-sg"
    Environment = var.environment
    Project     = "wordpress"
  }
}