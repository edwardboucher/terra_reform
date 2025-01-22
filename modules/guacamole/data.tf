resource "random_string" "seed_string" {
  length = 8
  special = false
  upper  = true
  lower = true
  numeric = true
}

data "aws_subnet" "guac_pub_subnet1" {
  id = var.guac_pub_subnet1_id
}

data "aws_subnet" "guac_pub_subnet2" {
  id = var.guac_pub_subnet2_id
}

data "aws_caller_identity" "current" {}

data "template_file" "guacdeploy" {
  template = "${file("${path.module}/guacdeploy.sh")}"
  vars = {
    s3_bucket_uri = join("", ["s3://",aws_s3_bucket.b.bucket,"/"])
    guac_admin_username = var.guac_admin_username
    guac_admin_pass = var.guac_admin_password
  }
}