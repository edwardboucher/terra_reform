# Tailscale Subnet Router Terraform Module

This module sets up a Tailscale Subnet Router on an AWS EC2 instance. It installs and configures Tailscale to advertise specified subnet CIDRs.

## Requirements

- Terraform
- AWS account
- Tailscale API authentication key (can be generated at https://login.tailscale.com/admin/settings/keys)

## Usage

```hcl
module "tailscale_subnet_router" {
  source              = "../modules/terraform-tailscale-subnet-router"
  ami_id              = "ami-026ebd4cfe2c043b2" # RHEL AMI
  instance_type       = "t3.micro"
  subnet_id           = "subnet-12345678"
  subnet_cidrs        = "10.0.0.0/24"
  tailscale_auth_key  = "tskey-auth-xxxxxxxxxxxxxxxxxx"
  tailnet_net         = <something>.ts.net"
  vm_name             = "my-tailscale-router"
  key_name            = "my-ssh-key"
  iam_role            = "my-instance-role"
  advertise_routes    = ["10.1.12.0/18", "10.1.12.0/24"]
  rh_username         = "username" #for RHEL license
  rh_password         = "password" #for RHEL license
}