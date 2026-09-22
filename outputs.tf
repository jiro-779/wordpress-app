output "alb_dns_name" {
  description = "DNS name of the WordPress ALB"
  value       = aws_lb.wordpress.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.wordpress.address
}

output "efs_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.wordpress.id
}

output "secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db.arn
}