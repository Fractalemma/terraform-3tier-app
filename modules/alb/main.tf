# Application Load Balancer
resource "aws_lb" "application_load_balancer" {
  name                       = "${var.module_prefix}-alb"
  internal                   = var.is_internal
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg_id]
  subnets                    = [var.sub_a_id, var.sub_b_id]
  enable_deletion_protection = false

  tags = {
    Name = "${var.module_prefix}-alb"
  }
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb



# Target Group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.module_prefix}-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group



# ALB Listener (HTTP -> redirect to target group)
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# See:
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener