resource "aws_ssm_parameter" "admin_password" {
  count       = var.store_admin_password ? 1 : 0
  name        = var.admin_password_ssm_name
  description = "Admin password for ${var.domain_name} (${aws_directory_service_directory.this.id})"
  type        = "SecureString"
  key_id      = var.admin_password_kms_key_id
  value       = local.admin_password
  tags        = var.tags
}
