Builds a guac server(s) behind and ALB<br>

EXAMPLE:<br>
module "guac001" {<br>
  source = "../modules/guacamole"<br>
  certificate_arn = module.base_guacserver_cert.certificate_arn<br>
  guac_pub_subnet1_id = module.vpc.public_subnet_ids[0]<br>
  guac_pub_subnet2_id = module.vpc.public_subnet_ids[1]<br>
  guac_admin_password = "yourmom20252025"<br>
}<br>
<br>
