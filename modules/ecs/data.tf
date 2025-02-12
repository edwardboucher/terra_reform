##get myIP
data "external" "getmyip" {
  program = ["/bin/bash", "${path.module}/getmyip.sh"]
}

data "aws_elb_service_account" "main" {}

resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

data "aws_subnet" "existing_pub_subnet1" {
  id = var.aws_subnet_public_1_id
}

data "aws_subnet" "existing_pub_subnet2" {
  id = var.aws_subnet_public_2_id
}

##################################
locals {
  container_definition = jsonencode([
    {
      name               = var.app_name
      image              = "${var.ecr_url}:${var.image_name}"
      portMappings = [
        {
          containerPort = var.container_ports
          hostPort      = var.container_ports
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = var.container_env_name
          value = var.container_env_value
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_ports}/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      mountPoints = [
        {
          sourceVolume  = "efs-storage"
          containerPath = var.container_volume_path
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}