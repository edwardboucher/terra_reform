variable "string_length" {
  type        = number
  description = "The desired length of the random string."
  default     = 16
  validation {
    condition     = var.string_length > 0
    error_message = "The string length must be greater than 0."
  }
}

variable "include_special_chars" {
  type        = bool
  description = "Whether to include special characters in the random string."
  default     = true
}

variable "include_uppercase" {
  type        = bool
  description = "Whether to include uppercase letters in the random string."
  default     = true
}

variable "include_lowercase" {
  type        = bool
  description = "Whether to include lowercase letters in the random string."
  default     = true
}

variable "include_numbers" {
  type        = bool
  description = "Whether to include numbers in the random string."
  default     = true
}

variable "min_uppercase" {
  type        = number
  description = "Minimum number of uppercase characters required.  Cannot exceed string_length."
  default     = 0
  validation {
    condition     = var.min_uppercase >= 0 && var.min_uppercase <= var.string_length
    error_message = "min_uppercase must be between 0 and string_length"
  }
}

variable "min_lowercase" {
  type        = number
  description = "Minimum number of lowercase characters required. Cannot exceed string_length."
  default     = 0
    validation {
    condition     = var.min_lowercase >= 0 && var.min_lowercase <= var.string_length
    error_message = "min_lowercase must be between 0 and string_length"
  }
}

variable "min_numbers" {
  type        = number
  description = "Minimum number of numeric characters required. Cannot exceed string_length."
  default     = 0
    validation {
    condition     = var.min_numbers >= 0 && var.min_numbers <= var.string_length
    error_message = "min_numbers must be between 0 and string_length"
  }
}

variable "min_special" {
  type        = number
  description = "Minimum number of special characters required. Cannot exceed string_length."
  default     = 0
    validation {
    condition     = var.min_special >= 0 && var.min_special <= var.string_length
    error_message = "min_special must be between 0 and string_length"
  }
}
