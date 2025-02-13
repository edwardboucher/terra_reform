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

# Enhanced ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

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

# Enhanced ECS Service with proper health check
resource "aws_ecs_service" "app" {
  name                              = "${var.app_name}-${var.environment}-service"
  cluster                          = aws_ecs_cluster.main.id
  task_definition                  = aws_ecs_task_definition.app.arn
  desired_count                    = 2
  launch_type                      = "FARGATE"
  health_check_grace_period_seconds = 120

  network_configuration {
    subnets          = [var.aws_subnet_public_1_id, var.aws_subnet_public_2_id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.app.arn
  #   container_name   = var.app_name
  #   container_port   = var.container_ports
  # }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Environment = var.environment
    Name        = "${var.app_name}-service"
  }
}

# Enhanced ALB Target Group
resource "aws_lb_target_group" "app" {
  name        = "${substr(var.app_name, 0, 16)}-${var.environment}"
  port        = var.container_ports
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