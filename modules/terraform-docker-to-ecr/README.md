# Docker to ECR Terraform Module

This module pulls a Docker image from Docker Hub, tags it, and pushes it to an AWS Elastic Container Registry (ECR). It can either create a new ECR repository or use an existing one.

## Features

- Pulls a Docker image from Docker Hub.
- Pushes the image to AWS ECR.
- Optionally creates a new ECR repository if one doesn't exist.
- Supports image scanning and encryption settings for ECR.

## Requirements

- Docker CLI installed locally.
- AWS CLI installed locally and configured with appropriate credentials.

## Inputs

- `region`: AWS region to deploy the resources in.
- `docker_hub_image`: The Docker Hub image to pull (e.g., `nginx:latest`).
- `image_tag`: The tag for the image in ECR (default: `latest`).
- `create_ecr`: Whether to create a new ECR repository (default: `true`).
- `ecr_repository_name`: Name of the ECR repository.
- Other inputs for customization are in `variables.tf`.

## Outputs

- `ecr_repository_name`: The name of the ECR repository.
- `ecr_repository_uri`: The URI of the ECR repository.

## Example Usage

```hcl
module "docker_to_ecr" {
  source               = "../modules/terraform-docker-to-ecr"
  region               = "us-east-1"
  docker_hub_images    = ["nginx:latest", "redis:alpine"]
  image_tags           = ["nginx-custom", "redis-custom"]
  create_ecr           = true
  ecr_repository_name  = "my-ecr-repo"
  ecr_scan_on_push     = true
  ecr_encryption_type  = "AES256"
  tags = {
    Environment = "production"
    Project     = "docker-to-ecr"
  }
}