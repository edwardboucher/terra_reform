resource "local_file" "ssh_key_guac" {
  # Use count to conditionally create the resource
  count = var.create_ssh_key_file ? 1 : 0
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
  # Optional: Set file permissions for increased security
  file_permission = "0600"
}

output "key_name" {
  value = aws_key_pair.key_pair.key_name
}