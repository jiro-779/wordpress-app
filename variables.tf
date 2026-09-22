variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev or prod"
  type        = string
}
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
}