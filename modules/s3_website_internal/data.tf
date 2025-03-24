data "aws_subnet" "s3_vpce_01" {
  id = var.subnet_id_01
}

data "aws_subnet" "s3_vpce_02" {
  id = var.subnet_id_02
}

data "aws_vpc" "discovered" {
  id = data.aws_subnet.s3_vpce_01.vpc_id
}