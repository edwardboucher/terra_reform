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