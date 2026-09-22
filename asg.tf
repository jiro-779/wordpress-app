resource "aws_autoscaling_group" "wordpress" {
  name = "${var.environment}-wp-asg"

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  vpc_zone_identifier = data.terraform_remote_state.platform.outputs.private_subnet_ids

  target_group_arns = [
    aws_lb_target_group.wordpress.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  depends_on = [
    aws_efs_mount_target.private_1,
    aws_efs_mount_target.private_2
  ]

  tag {
    key                 = "Name"
    value               = "${var.environment}-wp-ec2"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "wordpress"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.environment}-wp-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.wordpress.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}