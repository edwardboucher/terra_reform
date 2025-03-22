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