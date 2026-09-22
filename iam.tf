resource "aws_iam_role" "ec2" {
  name = "${var.environment}-wp-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-wp-ec2-role"
    Environment = var.environment
    Project     = "wordpress"
  }
}


resource "aws_iam_role_policy" "ec2_secrets" {
  name = "${var.environment}-wp-secrets-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = aws_secretsmanager_secret.db.arn
      },
      {
        Effect = "Allow"

        Action = [
          "kms:Decrypt"
        ]

        Resource = data.terraform_remote_state.platform.outputs.kms_key_arn
      }
    ]
  })
}


resource "aws_iam_instance_profile" "ec2" {
  name = "${var.environment}-wp-ec2-profile"
  role = aws_iam_role.ec2.name
}