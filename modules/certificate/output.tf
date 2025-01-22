output "domain_id" {
    value=data.aws_route53_zone.base_domain.zone_id
    description = "domain ID"
}

output "certificate_arn" {
    value=aws_acm_certificate.certificate.arn
    description = "cert ARN"
}