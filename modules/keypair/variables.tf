variable "key_name" {
  type = string
  default = "keypair_01"
}

variable "algorithm" {
  type = string
  default = "RSA"
}

variable "rsa_bits" {
  type = number
  default = "4096"
}

variable "create_ssh_key_file" {
  description = "Whether to create the SSH key file"
  type        = bool
  default     = false
}