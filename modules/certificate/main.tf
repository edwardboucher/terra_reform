terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"
    }
  }
}

data "aws_route53_zone" "base_domain" {
  name = var.domain_name # TODO put your own DNS in here!
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  #server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.acme_email_address # TODO put your own email in here!
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.registration.account_key_pem
  #common_name               = data.aws_route53_zone.base_domain.name
  common_name               = "${var.san_name}.${data.aws_route53_zone.base_domain.name}"
  subject_alternative_names = ["${var.san_name}.${data.aws_route53_zone.base_domain.name}"]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.base_domain.zone_id
      AWS_DEFAULT_REGION    = "us-east-1"  # OPTIONAL
    }
  }

  depends_on = [acme_registration.registration]
}

resource "aws_acm_certificate" "certificate" {
  certificate_body  = acme_certificate.certificate.certificate_pem
  private_key       = acme_certificate.certificate.private_key_pem
  certificate_chain = acme_certificate.certificate.issuer_pem
}