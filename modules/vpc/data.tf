resource "random_string" "random_suffix" {
  length  = 8
  special = false
  upper   = false
}

data "aws_availability_zones" "available" {}

data "aws_subnet" "selected_pub1" {
  id = aws_subnet.public[0].id
}

data "aws_subnet" "selected_priv1" {
  id = aws_subnet.private[0].id
}

data "aws_subnet" "selected_pub2" {
  id = aws_subnet.public[1].id
}

data "aws_subnet" "selected_priv2" {
  id = aws_subnet.private[1].id
}

# import {
#   to = aws_default_route_table.default
#   id = aws_vpc.this.id
# }