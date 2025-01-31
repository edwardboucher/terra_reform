#Example 01 with RDS-postgresql (works with realhandsonlabs.com sandbox with random subdomain -see zone_name_pattern)

module "global_rando" {
  source = "github.com/edwardboucher/terra_reform/modules/global_constants"
  string_length = 10
}
  
module "vpc" {
 source = "github.com/edwardboucher/terra_reform/modules/vpc"
  public_subnet_count = 2
  private_subnet_count = 2
  region        = "us-east-1"
  vpc_cidr      = "10.0.0.0/16"
  name          = "my-vpc-${module.global_rando.random_suffix_global}"
  tags          = { "Environment" = "Dev" }
  log_retention = 14
  usePrivateNAT = true
}

module "guac_psql" {
  source = "github.com/edwardboucher/terra_reform/modules/database"

  database_type     = "postgresql"
  #must be "guacamoledb" for the docker compose/ prepare.sh script process to work
  database_name     = "guacamoledb"
  engine_version    = "17.1"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  username = "guacamole_user"
  password = module.global_rando.random_suffix_global
  db_subnet1_id = module.vpc.private_subnet_ids[0]
  db_subnet2_id = module.vpc.private_subnet_ids[1]
  vpc_security_group_ids = [module.guac001.database_security_group[0].id]
}

module "guac001" {
  source = "github.com/edwardboucher/terra_reform/modules/guacamole"
  certificate_arn = module.base_guacserver_cert.certificate_arn
  guac_pub_subnet1_id = module.vpc.public_subnet_ids[0]
  guac_pub_subnet2_id = module.vpc.public_subnet_ids[1]
  guac_admin_password = "<ch@ngeME!!>"
  use_rds = true
  #
  guac_db_host = module.guac_psql.database_endpoint
  guac_db_address = module.guac_psql.database_address
  guac_db_name = "guacamoledb"
  guac_db_username = module.guac_psql.database_username
  guac_db_password = module.guac_psql.database_password
}  

module "demo_dns_record" {
  source = "github.com/edwardboucher/terra_reform/modules/dns_record"

  zone_name_pattern = ".*\\.realhandsonlabs\\.net"  # Regex pattern
  record_name      = "guac"
  record_type      = "CNAME"
  record_values    = [module.guac001.loadbalancer_dns]
  record_ttl       = 300
}

module "base_guacserver_cert" {
  source = "github.com/edwardboucher/terra_reform/modules/certificate"

  acme_email_address = "<changeme@yourdomain.com>"
  domain_name = module.demo_dns_record.selected_zone_name
  san_name = "guac22"
}

output "demo_dns_record_out" {
  value = module.demo_dns_record
}

output "db_engine_out" {
  value = data.aws_rds_engine_version.test
}

module "tailscale_subnet_router" {
  #source              = "github.com/edwardboucher/terra_reform/modules/terraform-tailscale-subnet-router"
  source              = "../modules/terraform-tailscale-subnet-router"
  ami_id              = "ami-026ebd4cfe2c043b2" # RHEL AMI
  instance_type       = "t3.micro"
  ts_router_subnet_id = module.vpc.public_subnet_ids[0]
  subnet_cidrs        = "10.0.0.0/24"
  tailscale_auth_key  = "tskey-api-<changeme>"
  vm_name             = "my-tailscale-router"
  key_name            = "my-ssh-key"
  iam_role            = "my-instance-role"
  advertise_routes    = [module.vpc.vpc_cidr_block]
  rh_username         = "<changeme_user>"
  rh_password         = "<changeme_pass>"
  tailscale_net       = "<changeme>.ts.net"
  refresh_tailscale_main_acl = false
}

###########################################

#Example 02 without RDS and using containerized postgresql (works with realhandsonlabs.com sandbox with random subdomain -see zone_name_pattern)

module "global_rando" {
  source = "github.com/edwardboucher/terra_reform/modules/global_constants"
  string_length = 10
}
  
module "vpc" {
 source = "github.com/edwardboucher/terra_reform/modules/vpc"
  public_subnet_count = 2
  private_subnet_count = 2
  region        = "us-east-1"
  vpc_cidr      = "10.0.0.0/16"
  name          = "my-vpc-${module.global_rando.random_suffix_global}"
  tags          = { "Environment" = "Dev" }
  log_retention = 14
  usePrivateNAT = true
}

module "guac001" {
  source = "github.com/edwardboucher/terra_reform/modules/guacamole"
  certificate_arn = module.base_guacserver_cert.certificate_arn
  guac_pub_subnet1_id = module.vpc.public_subnet_ids[0]
  guac_pub_subnet2_id = module.vpc.public_subnet_ids[1]
  guac_admin_password = "<ch@ngeME!!>"
  use_rds = false
  #
}  

module "demo_dns_record" {
  source = "github.com/edwardboucher/terra_reform/modules/dns_record"

  zone_name_pattern = ".*\\.realhandsonlabs\\.net"  # Regex pattern
  record_name      = "guac"
  record_type      = "CNAME"
  record_values    = [module.guac001.loadbalancer_dns]
  record_ttl       = 300
}

module "base_guacserver_cert" {
  source = "github.com/edwardboucher/terra_reform/modules/certificate"

  acme_email_address = "<changeme@yourdomain.com>"
  domain_name = module.demo_dns_record.selected_zone_name
  san_name = "guac22"
}

output "demo_dns_record_out" {
  value = module.demo_dns_record
}

output "db_engine_out" {
  value = data.aws_rds_engine_version.test
}

module "tailscale_subnet_router" {
  #source              = "github.com/edwardboucher/terra_reform/modules/terraform-tailscale-subnet-router"
  source              = "../modules/terraform-tailscale-subnet-router"
  ami_id              = "ami-026ebd4cfe2c043b2" # RHEL AMI
  instance_type       = "t3.micro"
  ts_router_subnet_id = module.vpc.public_subnet_ids[0]
  subnet_cidrs        = "10.0.0.0/24"
  tailscale_auth_key  = "tskey-api-<changeme>"
  vm_name             = "my-tailscale-router"
  key_name            = "my-ssh-key"
  iam_role            = "my-instance-role"
  advertise_routes    = [module.vpc.vpc_cidr_block]
  rh_username         = "<changeme_user>"
  rh_password         = "<changeme_pass>"
  tailscale_net       = "<changeme>.ts.net"
  refresh_tailscale_main_acl = false
}