variable "region" {
  description = "AWS region to deploy the resources in"
  type        = string
}

variable "docker_hub_images" {
  description = "The list of Docker Hub images (including tags) to pull, e.g., ['nginx:latest', 'redis:alpine']"
  type        = list(string)
}

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
