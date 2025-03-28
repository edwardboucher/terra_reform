# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}

# Create the Key Pair
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.key_pair.public_key_openssh
}