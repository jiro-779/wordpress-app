aws_region  = "eu-north-1"
environment = "dev"

ec2_instance_type    = "t3.micro"
asg_min_size         = 1
asg_max_size         = 2
asg_desired_capacity = 1

db_instance_class = "db.t3.micro"
db_multi_az       = false