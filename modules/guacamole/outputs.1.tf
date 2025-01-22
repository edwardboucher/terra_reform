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