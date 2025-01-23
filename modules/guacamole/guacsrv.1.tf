# Guacamole server containing docker images.

# data "template_file" "guacdeploy"{
#   template = "${file("./guacdeploy.sh")}"

#   vars = {
#     # db_ip = "${aws_db_instance.guacdb.address}"
#     # db_user = "${var.db_user}"
#     # db_password = "${var.db_password}"
#   }
# }

data "template_cloudinit_config" "guacdeploy_config" {
  gzip = false
  base64_encode = false

  part {
    filename     = "guacdeploy.sh"
    #content_type = "text/cloud-config"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.guacdeploy.rendered}"
  }
}

# Just going to deploy 1 guacamole server for now into one subnet, will add another soon 

resource "aws_instance" "guac-server1" {
  ami = "${var.guacsrv_ami}"
  vpc_security_group_ids = ["${aws_security_group.guac-sec.id}", "${aws_security_group.allout.id}"]
  instance_type = "${var.guacsrv_instance_type}"
  subnet_id =  var.guac_pub_subnet1_id
  key_name = aws_key_pair.key_pair.key_name
  associate_public_ip_address = false
    Name = "rsa_guac_server_01"
    DeployedBy = "terraform"
    tostop = "true"
  }
  # Needs the bastion server to exist since it runs the mysql init script before it can connect to the db
  # depends_on = ["aws_instance.bastion-server1"]
  user_data = "${data.template_cloudinit_config.guacdeploy_config.rendered}"
  iam_instance_profile = aws_iam_instance_profile.guac_profile.name
}