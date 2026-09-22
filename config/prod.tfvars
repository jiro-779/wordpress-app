aws_region  = "eu-north-1"
environment = "prod"

ec2_instance_type    = "t3.medium"
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2

db_instance_class = "db.t3.medium"
db_multi_az       = true