# Tailscale Subnet Router Terraform Module

This module sets up a Tailscale Subnet Router on an AWS EC2 instance. It installs and configures Tailscale to advertise specified subnet CIDRs.

## Requirements

- Terraform
- AWS account
- Tailscale API authentication key (can be generated at https://login.tailscale.com/admin/settings/keys)

## acl block that allows auto accept of advertized routes given a machine agent tag:

	"autoApprovers": {
		"routes": {
			"0.0.0.0/0": [
				"tag:vpc-peering",
				"autogroup:admin",
			],
		},
	}

## Usage

module "tailscale_subnet_router" {
  source              = "../modules/terraform-tailscale-subnet-router"
  ami_id              = "ami-026ebd4cfe2c043b2" # RHEL AMI
  instance_type       = "t3.micro"
  ts_router_subnet_id = module.vpc_base.public_subnet_ids[0]
  #subnet_id           = module.vpc_base.private_subnet.ids[0]
  subnet_cidrs        = "10.0.0.0/24"
  tailscale_auth_key  = "tskey-api-xxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  vm_name             = "my-tailscale-router"
  key_name            = "my-ssh-key"
  iam_role            = "my-instance-role"
  advertise_routes    = [var.vpc_cidr]
  rh_username         = "username_redhat"
  rh_password         = "password_redhat
  tailscale_net       = "tailxxxx.ts.net"
  tailscale_key       = "tskey-api-xxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
}