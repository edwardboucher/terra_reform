#get myIP
data "external" "getmyip" {
  program = ["/bin/bash", "${path.module}/getmyip.sh"]
}

#get myIP
data "external" "getmyip_priv" {
  program = ["/bin/bash", "${path.module}/getmyip_priv.sh"]
}

#public access sg 

# allow all egress traffic
resource "aws_security_group" "allout" {
  name = "allout-secgroup"
  vpc_id = data.aws_subnet.guac_pub_subnet1.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "all out"
  }
}

# Security group definition
resource "aws_security_group" "guac-sec" {
  name = "guacserver-secgroup"
  vpc_id = data.aws_subnet.guac_pub_subnet1.vpc_id

  # Guac listens on 8443
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.guac_pub_subnet1.cidr_block,data.aws_subnet.guac_pub_subnet2.cidr_block]
    description = "GUAC access from VPC"
  }
  # SSH from within VPC (bastion connectivity)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =  [format("%s/%s",data.external.getmyip.result["internet_ip"],32)]
    description = "SSH c9 private address ia peering"
  }
  # ping access
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks =  [format("%s/%s",data.external.getmyip.result["internet_ip"],32)]
    description = "PING c9 private address ia peering"
  }
}

#Provision load balancer and associated security group

###############################################
## SECURITY GROUP DEFINITION 
###############################################

resource "aws_security_group" "lb-sec" {
  name = "lb-secgroup"
  vpc_id = data.aws_subnet.guac_pub_subnet1.vpc_id

 
  # HTTPS access from my IP
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks =  [format("%s/%s",data.external.getmyip.result["internet_ip"],32)]
    description = "default gui access from c9"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks =  [format("%s/%s",data.external.getmyip.result["internet_ip"],32)]
    description = "default gui access from c9"
  }
  
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks =   [data.aws_subnet.guac_pub_subnet1.cidr_block,data.aws_subnet.guac_pub_subnet2.cidr_block]
    description = "default gui access from on-prem NATd address"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks =   [data.aws_subnet.guac_pub_subnet1.cidr_block,data.aws_subnet.guac_pub_subnet2.cidr_block]
    description = "default gui access from on-prem NATd address - this is better than 8443"
  }
  egress {
      from_port = 8443
      to_port = 8443
      protocol = "tcp"
      cidr_blocks =  [data.aws_subnet.guac_pub_subnet1.cidr_block,data.aws_subnet.guac_pub_subnet2.cidr_block]
      description = "out all 8443 to vpc"
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks =  [data.aws_subnet.guac_pub_subnet1.cidr_block,data.aws_subnet.guac_pub_subnet2.cidr_block]
    description = "out all 443 to vpc"
  }

  #ping from anywhere - can be omitted if unnecessary
    ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks =  [format("%s/%s",data.external.getmyip.result["internet_ip"],32)]
    description = "default ping from c9"
  }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks =  [format("%s/%s",data.external.getmyip.result["internet_ip"],32)]
      description = "out all"
  }
}

resource "aws_security_group" "db_sec_group" {
  count = var.use_rds ? 1 : 0
  name   = "db_access_group_${random_string.seed_string.result}"
  vpc_id = data.aws_subnet.selected.vpc_id
  description = "DB Security Group for HTTP"
  # ingress {
  #   from_port   = 5432
  #   to_port     = 5432
  #   protocol    = "tcp"
  #   #cidr_blocks = [formatlist("%s/32", aws_instance.guac-server1.private_ip)]
  #   cidr_blocks = ["${aws_instance.guac-server1.private_ip}/32"]
  #   #cidr_blocks = ["10.0.0.0/16"]
  # }
}

resource "aws_security_group_rule" "allow_guac" {
  count = var.use_rds ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.db_sec_group[count.index].id
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.guac-server1.private_ip}/32"]
}