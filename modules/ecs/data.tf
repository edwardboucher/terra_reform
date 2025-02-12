##get myIP
data "external" "getmyip" {
  program = ["/bin/bash", "${path.module}/getmyip.sh"]
}

data "aws_elb_service_account" "main" {}

resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

data "aws_subnet" "existing_pub_subnet1" {
  id = var.aws_subnet_public_1_id
}

data "aws_subnet" "existing_pub_subnet2" {
  id = var.aws_subnet_public_2_id
}