> Vendored from terra_reform `modules/guacamole` @ a971fc2 (2026-10-28). Local change: embedded `provider "aws"` block removed so the caller's default_tags apply; `volume_tags` variable added for the server's EBS volumes.

Builds an external guac server(s) behind an ALB<br>
EXAMPLE 01:<br>
module "guac001" {<br>
  source = "github.com/edwardboucher/terra_reform/modules/guacamole"<br>
  certificate_arn = arn:aws:acm:us-east-2:xxxxxxxxxxxx:certificate/16fc2a47-a5b7-470b-81a2-xxxxxxxxxxxx<br>
  guac_pub_subnet1_id = subnet-0044ac22d123456789<br>
  guac_pub_subnet2_id = subnet-0044be22d123456789<br>
  use_rds = false #willuse container-based db<br>
  guac_admin_password = "yourpass20252025"<br>
}<br>
<br>

Builds an internal guac server(s) behind an ALB<br>
EXAMPLE 02:<br>
module "guac001" {<br>
  source = "github.com/edwardboucher/terra_reform/modules/guacamole"<br>
  certificate_arn = module.base_guacserver_cert.certificate_arn<br>
  guac_pub_subnet1_id = subnet-0044ac22d123456789<br>
  guac_pub_subnet2_id = subnet-0044be22d123456789<br>
  use_rds = true<br>
  guac_admin_password = "yourpass20252025"<br>
  guac_db_host = module.guac_psql.database_endpoint<br>
  guac_db_address = module.guac_psql.database_address<br>
  guac_db_name = "guacamoledb"<br>
  guac_db_username = module.guac_psql.database_username<br>
  guac_db_password = module.guac_psql.database_password<br>
  internal_lb         = true<br>
  associate_public_ip = false<br>
}<br>