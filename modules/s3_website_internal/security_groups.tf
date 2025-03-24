resource "aws_security_group" "load_balancer" {
  name = "${var.bucket_prefix}-${var.environment}-lb-sg"
  vpc_id = data.aws_subnet.s3_vpce_01.vpc_id

  #ssh from anywhere (unnecessary)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.discovered.cidr_block]
  }
  # ping access from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [data.aws_vpc.discovered.cidr_block]
  }
}