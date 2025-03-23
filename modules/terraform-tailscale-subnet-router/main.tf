# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tailscale = {
      source  = "tailscale/tailscale" // previously davidsbond/tailscale
      version = "0.16.2"
    }
  }

  required_version = ">= 1.2.0"
}

provider "tailscale" {
  #Use env variable `TAILSCALE_API_KEY` instead
  api_key = var.tailscale_auth_key
  #Can be set via the `TAILSCALE_TAILNET` environment variable
  tailnet = var.tailscale_net
  #base_url = "https://api.us.tailscale.com"
}

# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Create the Key Pair
resource "aws_key_pair" "key_pair_tailscale" {
  key_name   = var.ssh_key_name
  public_key = tls_private_key.key_pair.public_key_openssh
}
# # Save file
# resource "local_file" "ssh_key_tailscale" {
#   #filename = "${aws_key_pair.key_pair.key_name}.pem"
#   filename =  "${file("${aws_key_pair.key_pair.key_name}.pem")}"
#   content  = tls_private_key.key_pair.private_key_pem
# }

# Create a Virtual Machine for the Tailscale subnet router
resource "aws_instance" "tailscale_subnet_router" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.ts_router_subnet_id
  associate_public_ip_address = true
  key_name = aws_key_pair.key_pair_tailscale.key_name
  tags = {
    Name = "tailscale-${random_string.random_suffix.result}"
  }
  user_data = data.template_file.init-tailscale.rendered
  
}


# Output the instance ID and public IP
output "instance_id" {
  value = aws_instance.tailscale_subnet_router.id
}

output "instance_public_ip" {
  value = aws_instance.tailscale_subnet_router.public_ip
}

resource "tailscale_tailnet_key" "new" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  description   = "aws router key"
}

resource "tailscale_acl" "main" {
  count = var.refresh_tailscale_main_acl ? 1 : 0
  overwrite_existing_content = true
  acl = file("${path.module}/tailscale_acl.json")
}