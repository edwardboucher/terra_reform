# ##get myIP
# data "external" "getmyip" {
#   program = ["/bin/bash", "${path.module}/getmyip.sh"]
# }

# data "aws_elb_service_account" "main" {}

resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}