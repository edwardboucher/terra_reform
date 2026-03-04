# outputs.tf

output "random_suffix_global" {
  value     = random_string.random_suffix.result
  sensitive = true
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group managing the Tailscale subnet router."
  value       = aws_autoscaling_group.tailscale.name
}

output "launch_template_id" {
  description = "ID of the Launch Template used by the Auto Scaling Group."
  value       = aws_launch_template.tailscale.id
}

output "security_group_id" {
  description = "ID of the security group attached to the Tailscale subnet router instances."
  value       = aws_security_group.tailscale_node.id
}
