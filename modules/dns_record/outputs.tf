output "record_name" {
  description = "The created DNS record name"
  value       = aws_route53_record.this.name
}

output "record_fqdn" {
  description = "The created DNS record FQDN"
  value       = aws_route53_record.this.fqdn
}

output "selected_zone_id" {
  description = "The ID of the selected Route 53 zone"
  value       = data.aws_route53_zone.selected.zone_id
}

output "selected_zone_name" {
  description = "The name of the selected Route 53 zone"
  value       = data.aws_route53_zone.selected.name
}