variable "database_type" {
  description = "Type of database (mysql, postgresql, aurora, etc.)"
  type        = string
  default     = "mysql"
}

variable "database_type_engine" {
  description = "Type of database (mysql, postgresql, aurora, etc.)"
  type        = string
  default     = "postgres"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.medium"
}

variable "storage_type" {
  description = "Type of storage (gp2, io1, etc)"
  type        = string
  default     = "gp2"
}

variable "allocated_storage" {
  description = "Storage size in GB"
  type        = number
  default     = 20
}

variable "username" {
  description = "Database master username"
  type        = string
}

variable "password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

#added by (eboucher)
variable "db_subnet1_id" {
  type = string
  description = "ID of the first subnet from VPC"
  # validation {
  #   condition = data.guac_pub_subnet1_id.vpc_id == data.guac_pub_subnet2_id.vpc_id
  #   error_message = "Subnets must be in the same VPC"
  # }
}
variable "db_subnet2_id" {
  type = string
  description = "ID of the second subnet from VPC"
  # validation {
  #   condition = data.guac_pub_subnet2_id.vpc_id == data.guac_pub_subnet1_id.vpc_id
  #   error_message = "Subnets must be in the same VPC"
  # }
}