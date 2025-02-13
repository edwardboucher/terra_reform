# # Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = [var.aws_subnet_public_1_id, var.aws_subnet_public_2_id]
}

resource "aws_lb_target_group" "app" {
  name        = "${var.app_name}-app-tg"
  port        = var.container_ports             # Changed from 80 to 3000 to match container port
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.existing_pub_subnet1.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"  # Adjust this to match your app's health check endpoint
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
    matcher             = "200,302,404"  # Accept more status codes
  }
  lifecycle {
      create_before_destroy = true
      ignore_changes        = [name]
    }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  load_balancer_arn = module.aws_ecs_service.app.load_balancer.arn
  port              = var.lb_ports
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}