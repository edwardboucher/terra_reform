resource "random_string" "random_suffix" {
  length  = var.string_length
  special = false
  upper   = false
}

output "random_suffix_global" {
  value     = random_string.random_suffix.result
  sensitive = false
}
