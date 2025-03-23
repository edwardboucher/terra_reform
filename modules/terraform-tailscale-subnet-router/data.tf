resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

data "template_file" "init-tailscale" {
  template = file("${path.module}/aws-user-data-tailscale.sh.tpl")
  vars = {
    tailnet_key = "${tailscale_tailnet_key.new.key}"
    tailscale_tag = var.tailscale_tag
    routes      = join(",", var.advertise_routes)
    rh_username = var.rh_username
    rh_password = var.rh_password
  }
}

#get myIP
data "external" "getmyip" {
  program = ["/bin/bash", "${path.module}/getmyip.sh"]
}