# EFS Security Group
resource "aws_security_group" "efs" {
  name        = "${var.app_name}-efs-sg"
  description = "Allow EFS inbound traffic from ECS tasks"
  vpc_id      = data.aws_subnet.existing_pub_subnet1.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Update ECS Tasks Security Group to allow EFS traffic
resource "aws_security_group_rule" "ecs_tasks_efs" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks.id
  source_security_group_id = aws_security_group.efs.id
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-ecs-tasks-sg"
  description = "ECS Tasks Security Group"
  vpc_id      = data.aws_subnet.existing_pub_subnet1.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Groups
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = data.aws_subnet.existing_pub_subnet1.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    #use MYIP possibly
    cidr_blocks = length(var.custom_ingress_cidr) > 0 ? var.custom_ingress_cidr : [format("%s/%s", data.external.getmyip.result["internet_ip"], "32")]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}