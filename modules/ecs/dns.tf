module "demo_dns_record" {
  source = "../modules/dns_record"

  zone_name_pattern = ".*\\.realhandsonlabs\\.net"  # Regex pattern
  record_name      = "anthropic-demo"
  record_type      = "CNAME"
  record_values    = [aws_lb.main.dns_name]
  record_ttl       = 300
}