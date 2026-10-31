# managed_ad

AWS Managed Microsoft AD with:

- Admin password generated (or supplied) and stored as an SSM SecureString, by default at `/directory/Microsoft-ad/password`
- Optional CloudWatch Logs forwarding of domain controller security logs
- Optional AD user creation through the Directory Service Data API, with each user's password stored at `<user_password_ssm_prefix>/<username>`

User creation runs the `aws` CLI on the machine running Terraform (aws CLI 2.18 or later, same account/region credentials as the provider).

```hcl
module "directory" {
  source = "./modules/managed_ad"

  name        = "corp"
  domain_name = "corp.example.local"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids

  # optional overrides
  # admin_password          = var.my_password      # default: random
  # store_admin_password    = true                 # default: true
  # admin_password_ssm_name = "/my/path/password"  # default: /directory/Microsoft-ad/password

  users = {
    jdoe = { given_name = "Jane", surname = "Doe", groups = ["AWS Delegated Administrators"] }
  }
}
```
