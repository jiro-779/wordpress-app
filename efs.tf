resource "aws_efs_file_system" "wordpress" {
  creation_token = "${var.environment}-wp-efs"
  encrypted      = true
  kms_key_id     = data.terraform_remote_state.platform.outputs.kms_key_arn

  tags = {
    Name        = "${var.environment}-wp-efs"
    Environment = var.environment
    Project     = "wordpress"
  }
}
resource "aws_efs_mount_target" "private_1" {
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = data.terraform_remote_state.platform.outputs.private_subnet_ids[0]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "private_2" {
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = data.terraform_remote_state.platform.outputs.private_subnet_ids[1]
  security_groups = [aws_security_group.efs.id]
}