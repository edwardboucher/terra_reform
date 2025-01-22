# main.tf

# Data for the caller's AWS account ID
data "aws_caller_identity" "current" {}

# Create an ECR repository if it doesn't already exist
resource "aws_ecr_repository" "ecr_repo" {
  count = var.create_ecr ? 1 : 0

  name                 = var.ecr_repository_name
  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }
  encryption_configuration {
    encryption_type = var.ecr_encryption_type
  }
  tags = var.tags
}

# If using an existing ECR repository, fetch its details
data "aws_ecr_repository" "existing_repo" {
  count = var.create_ecr ? 0 : 1
  name  = var.ecr_repository_name
}

# Set the required provider and versions
terraform {
  required_providers {
    # We recommend pinning to the specific version of the Docker Provider you're using
    # since new versions are released frequently
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}
# # Docker login to AWS ECR
# provider "docker" {}

resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command = <<-EOF
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com
    EOF
  }
}

# Loop through the images and process them
resource "null_resource" "docker_process_images" {
  count = length(var.docker_hub_images)

  triggers = {
    image       = var.docker_hub_images[count.index]
    ecr_repo    = var.ecr_repository_name
    image_tag   = var.image_tags[count.index]
  }

  provisioner "local-exec" {
  command = <<-EOF
    /usr/bin/docker pull ${var.docker_hub_images[count.index]} &&
    /usr/bin/docker tag ${var.docker_hub_images[count.index]} ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository_name}:${var.image_tags[count.index]} &&
    /usr/bin/docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository_name}:${var.image_tags[count.index]}
  EOF
}

  depends_on = [null_resource.docker_login]
}