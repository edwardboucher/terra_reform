# main.tf
# Get all zones first
data "aws_route53_zones" "all" {}

# Then get the specific zone using the first match
data "aws_route53_zone" "selected" {
  zone_id  = [
    for id in data.aws_route53_zones.all.ids : id
    if can(regex(var.zone_name_pattern, data.aws_route53_zone.details[id].name))
  ][0]
  private_zone = false
}

# Get zone details
data "aws_route53_zone" "details" {
  for_each = toset(data.aws_route53_zones.all.ids)
  zone_id  = each.value
}