# outputs.tf

output "random_suffix_global" {
  value     = random_string.random_suffix.result
  sensitive = true
}

output "tailscale_router_public_ip" {
  description = "The public IP address of the Tailscale subnet router."
  value       = aws_instance.tailscale_subnet_router.public_ip
}

output "tailscale_router_id" {
  description = "The instance ID of the Tailscale subnet router."
  value       = aws_instance.tailscale_subnet_router.id
}
