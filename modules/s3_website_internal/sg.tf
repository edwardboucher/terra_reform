# Create a security group for the S3 endpoint
resource "aws_security_group" "s3_endpoint_sg" {
  name        = "${var.bucket_prefix}-s3-endpoint-sg-${var.environment}"
  description = "Security group for S3 VPC endpoint - managed by Terraform"
  vpc_id      = data.aws_subnet.s3_vpce_01.vpc_id

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.discovered.cidr_block]
    description = "Allow incoming HTTP connections"
  }

  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [data.aws_vpc.discovered.cidr_block]
    description = "Allow all OUT"
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.bucket_prefix}-s3-endpoint-sg-${var.environment}"
      Description = "Security group for S3 VPC endpoint"
    }
  )
}

resource "aws_security_group" "load_balancer" {
  name = "${var.bucket_prefix}-${var.environment}-lb-sg"
  vpc_id = data.aws_subnet.s3_vpce_01.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.discovered.cidr_block]
    description = "Allow incoming HTTP connections"
  }

  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [data.aws_vpc.discovered.cidr_block]
    description = "Allow all OUT"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.discovered.cidr_block]
    description = "Allow ougoing HTTP connections"
  }
}