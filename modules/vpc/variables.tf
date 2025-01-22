variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "number of subnets-  dividing the VPC CIDR"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "number of subnets-  dividing the VPC CIDR"
  type        = number
  default     = 2
}

variable "subnet_prefix" {
  description = "Subnet prefix size for dividing the VPC CIDR"
  type        = number
  default     = 8
}

variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "log_retention" {
  description = "Retention period for VPC flow logs in days"
  type        = number
  default     = 7
}

variable "region" {
  description = "where"
  type        = string
  default     = "us-east-1"
}