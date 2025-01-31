output "guacamole_admin_pass" {
    value = random_string.db_pass.result
    description = "used for 'guacadmin' and db pass"
}

output "guacamole_admin_username" {
    value = var.guac_admin_username
    description = "used for possible 'guacadmin' replacement"
}

output "seed_string" {
  value = random_string.seed_string
}

output "generated_db_password" {
  value = random_string.db_pass.result
}

output "loadbalancer_dns" {
    value = aws_alb.alb.dns_name
}

output "guacamole_instance_id" {
    value = aws_instance.guac-server1.id
    description = "guac instance ID"
}

output "guacamole_instance_private_ip" {
    value = aws_instance.guac-server1.private_ip
    description = "guac instance internal IP"
}

output "database_security_group" {
    value = aws_security_group.db_sec_group
}