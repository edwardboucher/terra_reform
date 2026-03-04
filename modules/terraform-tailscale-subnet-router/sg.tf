resource "aws_security_group" "tailscale_node" {
  name        = "tailscale-sg-${random_string.random_suffix.result}"
  description = "Allow incoming traffic to the Tailscale subnet router"
  vpc_id      = data.aws_subnet.tf_target_subnet.vpc_id

  ingress {
    from_port   = 3478
    to_port     = 3478
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "STUN/TURN server for NAT traversal"
  }

  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Tailscale primary coordination port"
  }

  dynamic "ingress" {
    for_each = var.enable_ssh && var.ssh_allowed_cidr != "" ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowed_cidr]
      description = "SSH from allowed CIDR"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "tailscale-sg-${random_string.random_suffix.result}"
  })
}
