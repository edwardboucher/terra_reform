# Get subnet information for IP calculation
data "aws_subnet" "endpoint_subnets" {
  count = length(var.subnet_configurations)
  id    = var.subnet_configurations[count.index].subnet_id
}