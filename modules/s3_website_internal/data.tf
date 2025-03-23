data "aws_subnet" "s3_vpce_01" {
  id = var.subnet_id_01
}

data "aws_subnet" "s3_vpce_02" {
  id = var.subnet_id_02
}