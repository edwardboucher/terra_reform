terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
  # default_tags {
  #   tags = {
  #   Environment = "development"
  #   Application = "app-${random_string.random_suffix.result}"
  #   Stack = "superstack"
  #   }
  # }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { "Name" : "base-vpc-dev-${random_string.random_suffix.result}" })
}

resource "aws_subnet" "public" {
  count = var.public_subnet_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_prefix, count.index)
  #cidr_block              = local.public_subnet_cidrs
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { "Name" : "Public-${count.index + 1}" })
}

resource "aws_subnet" "private" {
  count = var.private_subnet_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_prefix, count.index + var.public_subnet_count)
  #cidr_block        = local.private_subnet_cidrs
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = merge(var.tags, { "Name" : "Private-${count.index + 1}" })
}

# # Generate subnet CIDR blocks dynamically
# locals {
#   public_subnet_cidrs  = cidrsubnets(var.vpc_cidr, var.public_subnet_count + var.private_subnet_count)[0:var.public_subnet_count]
#   private_subnet_cidrs = cidrsubnets(var.vpc_cidr, var.public_subnet_count + var.private_subnet_count)[var.public_subnet_count:]
# }

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { "Name" : "Public Route Table ${random_string.random_suffix.result}" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_flow_log" "this" {
  log_group_name         = aws_cloudwatch_log_group.this.name
  iam_role_arn           = aws_iam_role.this.arn
  vpc_id                 = aws_vpc.this.id
  traffic_type           = "ALL"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.name}-vpc-logs"
  retention_in_days = var.log_retention
}

resource "aws_iam_role" "this" {
  name = "${var.name}-flow-log-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "logs:PutLogEvents"
      Effect   = "Allow"
      Resource = aws_cloudwatch_log_group.this.arn
    }]
  })
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route = []

  tags = {
    Name = "Private Route Table ${random_string.random_suffix.result}"
  }
}

resource "aws_nat_gateway" "private_nat" {
  count = var.usePrivateNAT ? 1 : 0
  connectivity_type = "private"
  subnet_id         = aws_subnet.private[0].id
  tags = {
    Name = "gw_NAT_${random_string.random_suffix.result}"
  }
}

resource "aws_route" "private_nat" {
  count = var.usePrivateNAT ? 1 : 0
  route_table_id            = aws_default_route_table.default.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_nat[count.index].id
}