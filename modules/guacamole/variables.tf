# Global TF Variables 
variable "guacsrv_ami" {
  default = "ami-0e2c8caa4b6378d8c"
}
variable "guacsrv_instance_type" {
  default = "t2.medium"
}
variable "certificate_arn" {}

#added by DARPA (eboucher)
variable "guac_pub_subnet1_id" {
  type = string
  description = "ID of the first subnet from VPC"
  # validation {
  #   condition = data.guac_pub_subnet1_id.vpc_id == data.guac_pub_subnet2_id.vpc_id
  #   error_message = "Subnets must be in the same VPC"
  # }
}
variable "guac_pub_subnet2_id" {
  type = string
  description = "ID of the second subnet from VPC"
  # validation {
  #   condition = data.guac_pub_subnet2_id.vpc_id == data.guac_pub_subnet1_id.vpc_id
  #   error_message = "Subnets must be in the same VPC"
  # }
}
variable "s3_bucket_name" {
  default = "guacamole-source-001"
}
variable  "guac_admin_username" {
  default = "guacadmin"
}
variable  "guac_admin_password" {
  default = "!!guacadmin!!"
}  
variable  "region" {
  default = "us-east-1"
}
variable  "availability_zones" {
  default = ["us-east-1a","us-east-1b"]
}