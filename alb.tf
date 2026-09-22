resource "aws_lb" "wordpress" {
  name               = "${var.environment}-wp-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = data.terraform_remote_state.platform.outputs.public_subnet_ids

  tags = {
    Name        = "${var.environment}-wp-alb"
    Environment = var.environment
    Project     = "wordpress"
  }
}

resource "aws_lb_target_group" "wordpress" {
  name     = "${var.environment}-wp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.platform.outputs.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "${var.environment}-wp-tg"
    Environment = var.environment
    Project     = "wordpress"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}