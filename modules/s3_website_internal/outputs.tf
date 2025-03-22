output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.website_bucket.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.website_bucket.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "Website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website_bucket_website_config.website_endpoint
}

output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint for S3"
  value       = aws_vpc_endpoint.s3_endpoint.id
}

output "vpc_endpoint_dns_entries" {
  description = "DNS entries for the VPC endpoint"
  value       = aws_vpc_endpoint.s3_endpoint.dns_entry
}