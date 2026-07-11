# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this module is

This is one module (`modules/guacamole`) in the `terra_reform` Terraform module collection
(other modules live at `../../modules/*`: `vpc`, `database`, `certificate`, `dns_record`, `keypair`,
`ecs`, `ecr`, `s3_website_internal`, `terraform-tailscale-subnet-router`, etc.). It is consumed as a
Terraform source, not run standalone — there are no root-level `.tfvars` or backend config here.
`modules/guacamole/README.md` has copy-pasteable usage examples; the collection root `README.md`
has full multi-module examples wiring this module together with `vpc`, `database`, `certificate`,
and `dns_record`.

The module provisions one or more EC2 instances running Apache Guacamole (via Docker Compose)
behind an AWS ALB, fronted by ACM/ACME certs from the sibling `certificate` module. It optionally
wires the containerized Guacamole app to an external RDS Postgres instance (`modules/database`) or
falls back to a Postgres container running alongside Guacamole on the same instance.

## Commands

There is no build/lint/test tooling in this module (no CI config, no `*.tftest.hcl`). Validate
changes with the Terraform CLI directly from this directory:

```bash
terraform init
terraform validate
terraform plan   # requires guac_pub_subnet1_id, guac_pub_subnet2_id, certificate_arn, etc. — see README.md
```

Note the file naming convention here is non-standard: several `.tf` files carry a `.1.tf` suffix
(`guacsrv.1.tf`, `keypair.1.tf`, `outputs.1.tf`, `provider.1.tf`) alongside plain `.tf` files
(`data.tf`, `loadbalancer.tf`, `s3.tf`, `security_groups.tf`, `variables.tf`). Terraform loads all
`*.tf` files in a directory regardless of this suffix, so there is no load-order significance —
just follow existing naming when adding new files of the same logical type.

## Architecture

**Two deployment modes, controlled by `var.use_rds`:**
- `use_rds = false` (default): Postgres runs as a container alongside Guacamole on the same EC2
  instance. Renders `myfiles/docker-compose.yml.tpl` with a generated random password
  (`random_string.db_pass` in `s3.tf`).
- `use_rds = true`: Guacamole connects to an external database (typically the sibling `database`
  module's RDS instance). Renders `myfiles/docker-compose-rds.yml.tpl` using `guac_db_host`,
  `guac_db_address`, `guac_db_name`, `guac_db_username`, `guac_db_password`. The rendered compose
  file is picked with `count = var.use_rds ? 1 : 0` (`aws_s3_object.compose-yaml` vs.
  `compose-yaml-rds` in `s3.tf`) — when adding compose-file logic, both variants need updating.

**Deployment pipeline (this is the part that spans multiple files):**
1. `s3.tf` uploads the entire `myfiles/push-to-docker-host/` tree (the vendored
   `boschkundendienst/guacamole-docker-compose` project — hash generator, nginx template,
   prepare/reset scripts) plus the rendered `docker-compose.yml` to a per-run S3 bucket
   (`quac-source-${random_string.seed_string.result}`).
2. `data.tf` renders `guacdeploy.sh` (via `template_file`) with DB connection info, admin
   credentials, and the S3 bucket URI.
3. `guacsrv.1.tf` wraps that rendered script as `cloud-init` user-data and launches
   `aws_instance.guac-server1` (currently a single instance — the code comments note plans to add
   a second).
4. On boot, `guacdeploy.sh` installs Docker + AWS CLI, pulls the S3 bucket contents down, generates
   `init/initdb.sql` (via the vendored `guacamole_hash.py`), and — only `if use_rds`— runs that SQL
   against the external Postgres host via `psql` before `docker compose up -d`.
5. `loadbalancer.tf` puts an ALB (HTTPS on 8443 and 443, using `var.certificate_arn`) in front of
   the instance; `security_groups.tf` locks down ingress based on `var.internal_lb` (public vs.
   Tailscale-only access) and the caller's current IP (fetched via `getmyip.sh`/`getmyip_priv.sh`,
   wired in as `data "external"` blocks).

**IAM**: `s3.tf` creates a single IAM role/instance profile (`guac_profile`) with broad `s3:*` on
its own bucket, `ec2:Describe*`/`ssm:Get*`, and (as of `connections_sync.tf`)
`AmazonSSMManagedInstanceCore` so guac-server1 is SSM-managed (Ubuntu AMIs ship the SSM Agent
pre-installed; the role previously lacked the permissions for it to register). `guac_role_assume_role_policy`
currently allows `principals { type = "AWS", identifiers = ["*"] }` — a known-loose default called
out in an inline comment, not something to silently tighten without checking with the module owner.

**Connection resync** (`connections_sync.tf`): `guac_add_connections.sh` (called from
`guacdeploy.sh`) only runs once, at first boot. Adding entries to `var.guac_target_instances` after
guac-server1 is already up updates `aws_s3_object.connections-json` but doesn't reach the running
instance on its own — `null_resource.sync_connections` closes that gap by re-invoking the script
over `aws ssm send-command` (`AWS-RunShellScript`) whenever the connections list changes, matched
via a `md5(jsonencode(local.guac_connections))` trigger. Requires the AWS CLI on whoever runs
`terraform apply` (same assumption as `getmyip.sh`).

**Credentials flow**: `guac_admin_password` is validated in `variables.tf` (alphanumeric, ≤12
chars) and baked into `initdb.sql` via `guacamole_hash.py`. The DB password is either
auto-generated (`random_string.db_pass`, non-RDS mode) or passed in as `guac_db_password` (RDS
mode). Both defaults in `variables.tf` are intentionally weak placeholders meant to be overridden
by the caller — the module README even notes "this default pass will error out..on purpose."

**Legacy/inactive files**: `cert_request.tfbak` (`.tfbak`, not loaded by Terraform) is an older
ACME/Route53 cert-request approach superseded by the standalone `modules/certificate` module —
kept for reference only.
