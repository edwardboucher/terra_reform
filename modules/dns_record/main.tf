resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.record_name}.${data.aws_route53_zone.selected.name}"
  type    = var.record_type
  ttl     = var.record_ttl
  records = var.record_values
}