resource "aws_lb" "s3web-alb" {
  name               = aws_s3_bucket.website_bucket.id
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.s3_endpoint_sg.id]
  subnets            = [var.subnet_id_01, var.subnet_id_02]

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.id
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = {
    Name        = "${var.bucket_prefix}-${var.environment}-alb"
    Environment = "development"
  }
}

resource "aws_lb_target_group" "s3-target-endpoints" {
  name        = "s3-target-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_subnet.s3_vpce_01.vpc_id
  health_check {
    enabled  = true
    protocol = "HTTP"
    port     = 80
    matcher  = "200-299,307,405"
  }
}

// Target group attachment
resource "aws_lb_target_group_attachment" "tg_attachment_a" {
  #  for_each         = data.aws_network_interface.s3_endpoint_eni
  target_group_arn = aws_lb_target_group.s3-target-endpoints.arn
  #target_id        = formatlist(" ", data.aws_network_interfaces.s3-int-adapters.*.private_ip)
  target_id = local.subnet01_ipv4
  #target_id        = data.aws_network_interface.endpoint_interface1.private_ip
  port = 80
}
// Target group attachment
resource "aws_lb_target_group_attachment" "tg_attachment_b" {
  #  for_each         = data.aws_network_interface.s3_endpoint_eni
  target_group_arn = aws_lb_target_group.s3-target-endpoints.arn
  #target_id        = formatlist(" ", data.aws_network_interfaces.s3-int-adapters.*.private_ip)
  target_id = local.subnet02_ipv4
  #target_id        = data.aws_network_interface.endpoint_interface2.private_ip
  port = 80
}

// Listener
resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.s3web-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.s3-target-endpoints.arn
  }
}

resource "aws_lb_listener_rule" "rule_b" {
  listener_arn = aws_lb_listener.my_alb_listener.arn
  priority     = 1

  action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.s3-target-endpoints.arn
    redirect {
      host = "#{host}"
      #protocol    = "#{port}"
      protocol    = "HTTP"
      status_code = "HTTP_301"
      path        = "/#{path}index.html"
      query       = "#{query}"
    }
  }
  condition {
    path_pattern {
      values = ["*/"]
    }
  }
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.my_alb_listener.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }

  condition {
    query_string {
      key   = "health"
      value = "check"
    }

    query_string {
      value = "bar"
    }
  }
}