resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  user_data_template = var.os_distro == "rhel" ? (
    "${path.module}/aws-user-data-tailscale.sh.tpl"
  ) : "${path.module}/aws-user-data-tailscale-ubuntu.sh.tpl"

  user_data = templatefile(local.user_data_template, {
    tailnet_key   = tailscale_tailnet_key.new.key
    tailscale_tag = var.tailscale_tag
    routes        = join(",", var.advertise_routes)
    rh_username   = var.rh_username
    rh_password   = var.rh_password
  })
}

data "aws_subnet" "tf_target_subnet" {
  id = var.ts_router_subnet_id
}
