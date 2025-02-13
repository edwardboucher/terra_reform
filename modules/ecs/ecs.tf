# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [var.aws_subnet_public_1_id, var.aws_subnet_public_2_id]
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name        = "${substr(var.app_name, 0, 16)}-${var.environment}-tg"
  port        = var.container_port # Ensure this is a single integer
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.existing_pub_subnet1.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = var.environment
    Name        = "${var.app_name}-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.lb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.app_name}-cluster"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  volume {
    name = "efs-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.app.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.app.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = local.container_definition

  tags = {
    Environment = var.environment
    Name        = "${var.app_name}-task"
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name                              = "${var.app_name}-${var.environment}-service"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = [var.aws_subnet_public_1_id, var.aws_subnet_public_2_id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Environment = var.environment
    Name        = "${var.app_name}-service"
  }
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.app_name}-ecs-logs"
  retention_in_days = var.log_retention
}
