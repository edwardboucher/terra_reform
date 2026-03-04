# variables.tf

variable "ami_id" {
  description = "The AMI ID for the virtual machine."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to use."
  type        = string
  default     = "t3.micro"
}

variable "ts_router_subnet_id" {
  description = "The subnet ID where the Tailscale router will reside. When using a private subnet, a NAT gateway is required for Tailscale to reach its coordination servers."
  type        = string
}

variable "tailscale_api_key" {
  description = "The Tailscale API key for authenticating the provider. Can also be set via the TAILSCALE_API_KEY environment variable."
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
  default     = "linux-key-pair-tailscale"
}

variable "iam_role" {
  description = "Name of an existing IAM role to attach to the instance. When empty and enable_ssm is true, a role with AmazonSSMManagedInstanceCore is created automatically."
  type        = string
  default     = ""
}

variable "advertise_routes" {
  default     = ["172.31.0.0/16"]
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
  description = "Tailscale ACL tag applied to the subnet router node, used for route auto-approval."
  default     = "vpc-peering"
}

variable "rh_username" {
  type        = string
  description = "Red Hat subscription username. Required only when using a RHEL AMI. Leave empty to skip subscription-manager registration."
  default     = ""
  sensitive   = true
}

variable "rh_password" {
  type        = string
  description = "Red Hat subscription password. Required only when using a RHEL AMI. Leave empty to skip subscription-manager registration."
  default     = ""
  sensitive   = true
}

variable "tailscale_net" {
  description = "The Tailscale overlay network name (e.g. example.ts.net). Can also be set via the TAILSCALE_TAILNET environment variable."
  type        = string
  sensitive   = true
}

variable "refresh_tailscale_main_acl" {
  type    = bool
  default = false
}

variable "tailscale_acl_content" {
  type        = string
  description = "Custom Tailscale ACL JSON content. When provided, overrides the default ACL template bundled with the module."
  default     = ""
}

variable "os_distro" {
  type        = string
  description = "OS family for the instance. Determines the user-data script used. Accepted values: 'rhel', 'ubuntu', 'debian'."
  default     = "rhel"
  validation {
    condition     = contains(["rhel", "ubuntu", "debian"], var.os_distro)
    error_message = "os_distro must be one of: rhel, ubuntu, debian."
  }
}

variable "enable_ssm" {
  type        = bool
  description = "When true, an IAM role with AmazonSSMManagedInstanceCore is created (if iam_role is not provided), enabling AWS Systems Manager Session Manager access."
  default     = true
}

variable "enable_ssh" {
  type        = bool
  description = "When true, an SSH ingress rule is added to the security group for the CIDR specified in ssh_allowed_cidr."
  default     = true
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR block allowed for SSH ingress (e.g. '203.0.113.5/32'). Only used when enable_ssh is true. Leave empty to disable SSH ingress."
  default     = ""
}

variable "public_ip_enabled" {
  type        = bool
  description = "Whether to assign a public IP to the instance. Set to false when deploying in a private subnet behind a NAT gateway."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources created by this module."
  default     = {}
}
