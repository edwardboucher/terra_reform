variable "region" {
  description = "AWS region to deploy the resources in"
  type        = string
}

# variable "docker_hub_images" {
#   description = "The list of Docker Hub images (including tags) to pull, e.g., ['nginx:latest', 'redis:alpine']"
#   type        = list(string)
# }

variable "image_tags" {
  description = "The list of tags to use for the Docker images in ECR. Must match the number of docker_hub_images."
  type        = list(string)
}

variable "create_ecr" {
  description = "Whether to create a new ECR repository"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository. If create_ecr is false, this must match an existing repository"
  type        = string
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push for the ECR repository"
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "The encryption type for the ECR repository (e.g., 'AES256' or 'KMS')"
  type        = string
  default     = "AES256"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Variables
variable "app_name" {
  default = "anthropic-demo"
}

# Variables
variable "name" {
  default = "anthropic-alb"
}

variable "environment" {
  default = "dev"
}

#"your-api-key-here"  # Replace with actual API key
variable "docker_env_variables" {
  type = map 
    default = {
      anthopic_api_key = null,
      var1 = null
    }
}

#AWS region
variable "region" {
    default = "us-east-1"
}

#AWS region
variable "bucket_name" {
    default = "alb_log_bucket"
}

variable "container_port" {
    type = number
    default = "8080"
}

variable "container_port_streamlit" {
    type = number
    default = "8501"
}

variable "container_port_vnc" {
    type = number
    default = "6080"
}

variable "docker_build_dir" {
  type = string
  default = "app_computer_demo"
}

variable "app_source_type" {
  description = "The source type of the application code (local, git, s3)"
  type        = string
  default     = "local"
}

variable "app_source_path" {
  description = "Path or URL to the application code"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name (if using S3)"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 object key (if using S3)"
  type        = string
  default     = ""
}

variable "git_branch" {
  description = "Git branch to clone (if using Git)"
  type        = string
  default     = "main"
}

variable "image_name" {
  description = "local name for build image"
  type        = string
  default     = "anthropic-quickstarts-computer-use-demo-latest"
}

variable "efs_container_map_path" {
  description = "for efs mapping"
  type = string
  default = "/home/computeruse/.anthropic"
}