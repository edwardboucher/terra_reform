# Variables
variable "app_name" {
  default = "projectdemo"
}

# Variables
variable "name" {
  default = "project-alb"
}

variable "environment" {
  default = "dev"
}

#AWS region
variable "region" {
    default = "us-east-1"
}

variable "ecr_url" {
    type = string
}

#AWS region
variable "bucket_name" {
    default = "alb_log_bucket"
}

variable "container_ports" {
    type = number
    default = "8080"
}

variable "image_name" {
  default = "anthropic-quickstarts-computer-use-demo-latest"
}

variable "container_env_name" {
  default = "ANTHROPIC_API_KEY"
}

variable "container_env_value" {
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