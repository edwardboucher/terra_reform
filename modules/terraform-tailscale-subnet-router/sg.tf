#get myIP
data "external" "getmyip2" {
  program = ["/bin/bash", "${path.module}/getmyip.sh"]
}

resource "aws_security_group" "tailscale-node-sg" {
  name        = "linux-sg"
  description = "Allow incoming traffic to the Linux EC2 Instance"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #use MYIP
    cidr_blocks = [format("%s/%s", data.external.getmyip2.result["internet_ip"], "32")]
    description = "Allow incoming SSH connections"
  }
    ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #use MYIP
    cidr_blocks = [var.vpc_cidr]
    description = "Allow incoming SSH connections from ansible"
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "icmp"
    #use MYIP
    cidr_blocks = [format("%s/%s", data.external.getmyip2.result["internet_ip"], "32")]
    description = "Allow incoming ICMP connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}