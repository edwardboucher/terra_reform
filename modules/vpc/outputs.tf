output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidr01" {
  value = [data.aws_subnet.selected_pub1.cidr_block]
}

output "private_subnet_cidr01" {
  value = [data.aws_subnet.selected_priv1.cidr_block]
}

output "public_subnet_cidr02" {
  value = [data.aws_subnet.selected_pub2.cidr_block]
}

output "private_subnet_cidr02" {
  value = [data.aws_subnet.selected_priv2.cidr_block]
}