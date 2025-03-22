variable "environment" {
  description = "Environment name (e.g. dev, prod, staging)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC where the S3 endpoint will be created"
  type        = string
}

# variable "security_group_id" {
#   description = "Security group ID to be associated with the VPC endpoint"
#   type        = string
# }

variable "subnet_configurations" {
  description = "List of subnet configurations for the VPC endpoint"
  type = list(object({
    subnet_id = string
    ipv4      = optional(string) # Make IPv4 optional
  }))
  validation {
    condition     = length(var.subnet_configurations) > 0
    error_message = "At least one subnet configuration must be provided."
  }
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  validation {
    condition     = length(var.bucket_prefix) >= 3 && length(var.bucket_prefix) <= 14
    error_message = "Bucket prefix must be between 3 and 14 characters to allow for additional suffixes."
  }
}

variable "content_directory" {
  description = "Local directory containing files to upload to S3"
  type        = string
  default     = "myfiles/"
  validation {
    condition     = fileexists("${var.content_directory}/index.html")
    error_message = "The content directory must contain an index.html file."
  }
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable access logging for the S3 bucket"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region for the S3 service endpoint"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}