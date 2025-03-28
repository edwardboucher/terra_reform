#get myIP
data "external" "getmyip2" {
  program = ["/bin/bash", "${path.module}/getmyip.sh"]
}

resource "aws_security_group" "tailscale-node-sg" {
  name        = "tailscale-sg"
  description = "Allow incoming traffic to the Linux EC2 Instance"
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
    description = "tailscale's primary coordination port"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #use MYIP
    cidr_blocks = [format("%s/%s", data.external.getmyip2.result["internet_ip"], "32")]
    description = "Allow incoming SSH connections from current ip"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}