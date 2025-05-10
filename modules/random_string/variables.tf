variable "string_length" {
  type        = number
  description = "The length of the random string to generate."
  default     = 4 # Reasonable default
  validation {
    condition     = var.string_length > 0
    error_message = "The string length must be greater than zero."
  }
}

variable "include_special_chars" {
  type        = bool
  description = "Whether to include special characters in the random string."
  default     = false
}

variable "include_upper_chars" {
  type        = bool
  description = "Whether to include uppercase characters in the random string."
  default     = true
}

variable "include_lower_chars" {
  type        = bool
  description = "Whether to include lowercase characters in the random string."
  default     = true
}

variable "include_numbers" {
  type        = bool
  description = "Whether to include numbers in the random string."
  default     = true
}
