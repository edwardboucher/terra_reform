# Outputs
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "HOT_url" {
  value = "http://${module.demo_dns_record.record_name}:8080"
}