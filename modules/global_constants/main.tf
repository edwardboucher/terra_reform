resource "random_string" "random" {
  length      = var.string_length
  special     = var.include_special_chars
  upper       = var.include_uppercase
  lower       = var.include_lowercase
  number      = var.include_numbers
  min_upper   = var.min_uppercase
  min_lower   = var.min_lowercase
  min_numeric = var.min_numbers
  min_special = var.min_special
}
