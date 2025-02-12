variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "projectdemo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "container_ports" {
  description = "Container port mapping"
  type        = number
  default     = 8080
}

variable "ecr_url" {
  description = "ECR repository URL"
  type        = string
}

variable "image_name" {
  description = "Docker image name"
  type        = string
  default     = "anthropic-quickstarts-computer-use-demo-latest"
}