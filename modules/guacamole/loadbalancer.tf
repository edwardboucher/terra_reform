

###############################################
## ALB CONFIGURATION 
###############################################

resource "aws_alb" "alb" {
  subnets = [var.guac_pub_subnet1_id, var.guac_pub_subnet2_id]
  internal = false
  security_groups = ["${aws_security_group.lb-sec.id}"]
}

resource "aws_alb_target_group" "targ" {
  port = 8443
  protocol = "HTTPS"
  vpc_id = data.aws_subnet.guac_pub_subnet1.vpc_id
  health_check {
    path                = "/"
    port                = 8443
    protocol            = "HTTPS"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
}

resource "aws_alb_target_group_attachment" "attach_guac" {
  target_group_arn = "${aws_alb_target_group.targ.arn}"
  target_id = "${aws_instance.guac-server1.id}"
  port = 8443
}

resource "aws_alb_listener" "list" {
  default_action {
    target_group_arn = "${aws_alb_target_group.targ.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = 8443
  protocol = "HTTPS"
  certificate_arn = var.certificate_arn
}

resource "aws_alb_listener" "list2" {
  default_action {
    target_group_arn = "${aws_alb_target_group.targ.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_alb.alb.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = var.certificate_arn
}