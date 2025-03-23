# variables.tf

variable "ami_id" {
  description = "The AMI ID for the virtual machine (Ubuntu preferred)."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to use."
  type        = string
  default     = "t3.micro"
}

variable "ts_router_subnet_id" {
  description = "The subnet ID where the Tailscale router will reside."
  type        = string
}

variable "subnet_cidrs" {
  description = "The subnet CIDRs to advertise through Tailscale."
  type        = string
}

variable "tailscale_auth_key" {
  description = "The Tailscale authentication key for connecting the node."
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "The name tag for the Tailscale subnet router instance."
  type        = string
  default     = "tailscale-subnet-router"
}

variable "ssh_key_name" {
  description = "The SSH key name to access the instance."
  type        = string
}

variable "iam_role" {
  description = "The IAM role to attach to the instance, if needed."
  type        = string
  default     = ""
}

variable "advertise_routes" {
  default = ["172.31.0.0/16"]
  type        = list(string)
  description = <<EOF
  The routes (expressed as CIDRs) to advertise as part of the Tailscale Subnet Router.
  Example: ["10.1.0.0/18", "10.1.64.0/24"]
  EOF
  validation {
    condition     = can([for route in var.advertise_routes : cidrsubnet(route, 0, 0)])
    error_message = "All elements in the list must be valid CIDR blocks."
  }
}

variable "tailscale_tag" {
  type        = string
  description = "used for auto-approve"
  default     = "vpc-peering"
}
variable "rh_username" {
  type        = string
  description = "used for rh login for licenses"
}
variable "rh_password" {
  type        = string
  description = "used for rh login for licenses"
}

variable "tailscale_net" {
  description = "The Tailscaleoverlay network name"
  type        = string
}

variable "refresh_tailscale_main_acl" {
  type    = bool
  default = false
}