locals {
  short_name     = coalesce(var.short_name, upper(split(".", var.domain_name)[0]))
  admin_password = coalesce(var.admin_password, random_password.admin.result)
}

resource "random_password" "admin" {
  length           = 24
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!#%^*-_=+"
}

resource "aws_directory_service_directory" "this" {
  name        = var.domain_name
  short_name  = local.short_name
  description = var.description
  password    = local.admin_password
  edition     = var.edition
  type        = "MicrosoftAD"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  tags = merge(var.tags, { Name = var.domain_name })
}
