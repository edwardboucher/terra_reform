
# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  volume {
    name = "efs-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.app.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.app.id
        iam             = "DISABLED"
      }
    }
  }
    container_definitions = templatefile("${path.module}/container_definition_b.tpl", {
      app_name          = var.app_name
      #AWS ECR format = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr.name}:anthropic-quickstarts-computer-use-demo-latest"
      repository_url = "${var.ecr_url}:${var.image_name}"
      container_port = var.container_ports
      container_env_name = var.container_env_name
      container_env_value = var.container_env_value
  })
  depends_on = [null_resource.docker_push]
}

# ECS Service APP
resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

   load_balancer {
    target_group_arn = aws_lb_target_group.streamlit.arn
    container_name   = var.app_name
    container_port   = var.container_port_streamlit
  }

   load_balancer {
    target_group_arn = aws_lb_target_group.vnc.arn
    container_name   = var.app_name
    container_port   = var.container_port_vnc
  }

  depends_on = [aws_lb_listener.front_end]

  deployment_controller {
    type = "ECS"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 30
}