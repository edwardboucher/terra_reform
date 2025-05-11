resource "random_string" "seed_string" {
  length = 4
  special = false
  upper  = false
  lower = true
  numeric = false
}

data "aws_subnet" "guac_pub_subnet1" {
  id = var.guac_pub_subnet1_id
}

data "aws_subnet" "guac_pub_subnet2" {
  id = var.guac_pub_subnet2_id
}

data "aws_subnet" "selected" {
  id = var.guac_pub_subnet1_id
}

data "aws_caller_identity" "current" {}

data "template_file" "guacdeploy" {
  template = "${file("${path.module}/guacdeploy.sh")}"
  vars = {
    s3_bucket_uri = join("", ["s3://",aws_s3_bucket.b.bucket,"/"])
    guac_admin_username = var.guac_admin_username
    guac_admin_pass = var.guac_admin_password
    psql_hostname = var.guac_db_address
    psql_username = var.guac_db_username
    psql_dbname = var.guac_db_name
    psql_password = var.guac_db_password
    use_rds = var.use_rds
  }
}