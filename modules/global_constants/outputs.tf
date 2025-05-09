resource "random_string" "random_suffix" {
  length  = var.string_length
  special = var.include_special_chars
  upper   = var.include_upper_chars
  lower   = var.include_lower_chars  # Add this to control lower case
  number  = var.include_numbers # Add this to control numbers
}

output "random_string" {
  value     = random_string.random_suffix.result
  sensitive = true  # Consider making it sensitive if it's a password or secret
  description = "The generated random string."
}
