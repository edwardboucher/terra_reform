# Terraform Modules for Guacamole and Tailscale
==============================================

This repository contains a collection of Terraform modules for deploying Guacamole and Tailscale on AWS.

## Table of Contents

* [Example 01: Guacamole with RDS Postgresql](#example-01-guacamole-with-rds-postgresql)
* [Example 02: Guacamole without RDS using containerized Postgresql](#example-02-guacamole-without-rds-using-containerized-postgresql)
* [Example 03: Tailscale overlay network via Wireguard](#example-03-tailscale-overlay-network-via-wireguard)

## Example 01: Guacamole with RDS Postgresql
-----------------------------------------

This example demonstrates how to deploy Guacamole with RDS Postgresql on AWS.

### Terraform Code

```terraform
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
  guac_db_host = module.guac_psql.database_endpoint
  guac_db_address = module.guac_psql.database_address
  guac_db_name = "guacamoledb"
  guac_db_username = module.guac_psql.database_username
  guac_db_password = module.guac_psql.database_password
}

module "demo_dns_record" {
  source = "github.com/edwardboucher/terra_reform/modules/dns_record"
  zone_name_pattern = ".*\\.realhandsonlabs\\.net"
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
```

### Explanation

This example uses the following Terraform modules:

* `global_rando`: generates a random suffix for the VPC name
* `vpc`: creates a VPC with public and private subnets
* `guac_psql`: creates an RDS Postgresql database
* `guac001`: creates a Guacamole server with an RDS Postgresql database
* `demo_dns_record`: creates a DNS record for the Guacamole server
* `base_guacserver_cert`: creates an SSL certificate for the Guacamole server

## Example 02: Guacamole without RDS using containerized Postgresql
---------------------------------------------------------

This example demonstrates how to deploy Guacamole without RDS using containerized Postgresql on AWS.

### Terraform Code

```terraform
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
}

module "demo_dns_record" {
  source = "github.com/edwardboucher/terra_reform/modules/dns_record"
  zone_name_pattern = ".*\\.realhandsonlabs\\.net"
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
```

### Explanation

This example uses the following Terraform modules:

* `global_rando`: generates a random suffix for the VPC name
* `vpc`: creates a VPC with public and private subnets
* `guac001`: creates a Guacamole server without an RDS Postgresql database
* `demo_dns_record`: creates a DNS record for the Guacamole server
* `base_guacserver_cert`: creates an SSL certificate for the Guacamole server

## Example 03: Tailscale overlay network via Wireguard
----------------------------------------------

This example demonstrates how to deploy a Tailscale overlay network via Wireguard on AWS.

### Terraform Code

```terraform
module "tailscale_subnet_router" {
  source              = "../modules/terraform-tailscale-subnet-router"
  ami_id              = "ami-026ebd4cfe2c043b2"
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
```

### Explanation

This example uses the following Terraform module:

* `tailscale_subnet_router`: creates a Tailscale overlay network via Wireguard

## Outputs

The following outputs are available:

* `demo_dns_record_out`: The DNS record output
* `db_engine_out`: The database engine output

Note: This is not an exhaustive list of outputs, and you may need to add additional outputs depending on your specific use case.

### Contributing

Contributions are welcome! Please submit a pull request with your changes and a brief description of what you've added or modified.

### License

This repository is licensed under the [MIT License](https://opensource.org/licenses/MIT).

### Acknowledgments

This repository is based on the work of [Edward Boucher](https://github.com/edwardboucher) and the [Terraform community](https://github.com/hashicorp/terraform).
