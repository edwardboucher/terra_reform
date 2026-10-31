output "directory_id" {
  description = "Directory ID (d-xxxxxxxxxx)"
  value       = aws_directory_service_directory.this.id
}

output "domain_name" {
  description = "Directory FQDN"
  value       = aws_directory_service_directory.this.name
}

output "short_name" {
  description = "Directory NetBIOS name"
  value       = aws_directory_service_directory.this.short_name
}

output "dns_ip_addresses" {
  description = "Domain controller / DNS IP addresses"
  value       = sort(tolist(aws_directory_service_directory.this.dns_ip_addresses))
}

output "security_group_id" {
  description = "Security group AWS created for the domain controllers"
  value       = aws_directory_service_directory.this.security_group_id
}

output "admin_password" {
  description = "Directory Admin password"
  value       = local.admin_password
  sensitive   = true
}

output "admin_password_ssm_name" {
  description = "SSM parameter holding the Admin password (null when not stored)"
  value       = try(aws_ssm_parameter.admin_password[0].name, null)
}

output "user_password_ssm_names" {
  description = "SSM parameter per created user, keyed by username"
  value       = { for k, p in aws_ssm_parameter.user_password : k => p.name }
}
