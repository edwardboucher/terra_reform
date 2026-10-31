################################################################################
## directory
################################################################################
variable "name" {
  description = "Name prefix used for supporting resources (log group, log policy)"
  type        = string
}

variable "domain_name" {
  description = "Fully qualified domain name for the directory (e.g. corp.example.local)"
  type        = string
}

variable "short_name" {
  description = "NetBIOS name for the directory. Defaults to the first label of domain_name, upper-cased"
  type        = string
  default     = null
}

variable "edition" {
  description = "Managed AD edition: Standard or Enterprise"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Enterprise"], var.edition)
    error_message = "edition must be Standard or Enterprise."
  }
}

variable "description" {
  description = "Directory description"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC to deploy the domain controllers into"
  type        = string
}

variable "subnet_ids" {
  description = "Exactly two private subnet IDs in different availability zones"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) == 2
    error_message = "Managed Microsoft AD requires exactly two subnets in different AZs."
  }
}

variable "tags" {
  description = "Tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}

################################################################################
## admin ("Admin") password
################################################################################
variable "admin_password" {
  description = "Password for the directory 'Admin' account. Leave null to generate a random one"
  type        = string
  default     = null
  sensitive   = true
}

variable "store_admin_password" {
  description = "Store the Admin password as an SSM SecureString parameter"
  type        = bool
  default     = true
}

variable "admin_password_ssm_name" {
  description = "SSM parameter path used to store the Admin password"
  type        = string
  default     = "/directory/Microsoft-ad/password"
}

variable "admin_password_kms_key_id" {
  description = "KMS key for the SSM parameters. Null uses the AWS managed aws/ssm key"
  type        = string
  default     = null
}

################################################################################
## logging
################################################################################
variable "enable_log_forwarding" {
  description = "Forward domain controller security logs to CloudWatch Logs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention for directory logs"
  type        = number
  default     = 30
}

################################################################################
## users (created through the Directory Service Data API with the local aws CLI)
################################################################################
variable "users" {
  description = "AD users to create, keyed by sAMAccountName. Each gets a random password stored in SSM"
  type = map(object({
    given_name    = optional(string)
    surname       = optional(string)
    email_address = optional(string)
    groups        = optional(list(string), [])
  }))
  default = {}
}

variable "user_password_ssm_prefix" {
  description = "SSM path prefix for generated user passwords; each user is stored at <prefix>/<username>"
  type        = string
  default     = "/directory/Microsoft-ad/users"
}
