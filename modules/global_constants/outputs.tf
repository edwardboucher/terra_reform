resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

output "random_suffix_global" {
  value     = random_string.random_suffix.result
  sensitive = true
}