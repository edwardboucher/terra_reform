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

variable "lb_ports" {
  description = "load balancer front-end port mapping"
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

variable "container_env_name" {
  description = "Docker container ENV name"
  default = "ANTHROPIC_API_KEY"
}

variable "container_env_value" {
  description = "Docker container ENV value"
  default = "null"
}

variable "container_volume_path" {
  default = "/home/computeruse/.anthropic"
}

variable "aws_subnet_public_1_id" {
  type = string
}

variable "aws_subnet_public_2_id" {
  type = string
}

variable "custom_ingress_cidr" {
  description = "Custom CIDR blocks for ALB ingress. If not provided, uses the IP from getmyip script"
  type        = list(string)
  default     = []
}