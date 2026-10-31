# The AWS provider has no AD user resource, so users are created through the
# Directory Service Data API (aws ds-data) with the aws CLI on the machine
# running Terraform. Requires aws CLI >= 2.18 and credentials for the same
# account/region as the provider.

data "aws_region" "current" {}

resource "random_password" "user" {
  for_each         = var.users
  length           = 20
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!#%^*-_=+"
}

resource "aws_ssm_parameter" "user_password" {
  for_each    = var.users
  name        = "${var.user_password_ssm_prefix}/${each.key}"
  description = "Initial password for ${each.key}@${var.domain_name}"
  type        = "SecureString"
  key_id      = var.admin_password_kms_key_id
  value       = random_password.user[each.key].result
  tags        = var.tags
}

# Directory Service Data access is off by default on new directories.
resource "null_resource" "enable_data_access" {
  count = length(var.users) > 0 ? 1 : 0

  triggers = {
    directory_id = aws_directory_service_directory.this.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      AWS_REGION   = data.aws_region.current.name
      DIRECTORY_ID = aws_directory_service_directory.this.id
    }
    command = <<-EOT
      set -euo pipefail
      status() { aws ds describe-directory-data-access --directory-id "$DIRECTORY_ID" --query DataAccessStatus --output text; }
      if [ "$(status)" != "Enabled" ]; then
        aws ds enable-directory-data-access --directory-id "$DIRECTORY_ID" || true
      fi
      for i in $(seq 1 60); do
        [ "$(status)" = "Enabled" ] && exit 0
        sleep 10
      done
      echo "Directory data access did not reach Enabled" >&2
      exit 1
    EOT
  }
}

# Create (if missing), set the password (which also enables the account), then
# add group memberships. Safe to re-run.
resource "null_resource" "user" {
  for_each = var.users

  triggers = {
    directory_id = aws_directory_service_directory.this.id
    region       = data.aws_region.current.name
    username     = each.key
    attributes   = sha1(jsonencode(each.value))
    password     = sha1(aws_ssm_parameter.user_password[each.key].value)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      AWS_REGION    = self.triggers.region
      DIRECTORY_ID  = self.triggers.directory_id
      USERNAME      = each.key
      GIVEN_NAME    = coalesce(each.value.given_name, each.key)
      SURNAME       = coalesce(each.value.surname, "-")
      EMAIL_ADDRESS = each.value.email_address == null ? "" : each.value.email_address
      GROUPS        = join("\n", each.value.groups)
      PASSWORD      = random_password.user[each.key].result
    }
    command = <<-EOT
      set -euo pipefail
      if ! aws ds-data describe-user --directory-id "$DIRECTORY_ID" --sam-account-name "$USERNAME" >/dev/null 2>&1; then
        args=(--directory-id "$DIRECTORY_ID" --sam-account-name "$USERNAME" --given-name "$GIVEN_NAME" --surname "$SURNAME")
        [ -n "$EMAIL_ADDRESS" ] && args+=(--email-address "$EMAIL_ADDRESS")
        aws ds-data create-user "$${args[@]}" >/dev/null
        echo "created $USERNAME"
      fi
      aws ds reset-user-password --directory-id "$DIRECTORY_ID" --user-name "$USERNAME" --new-password "$PASSWORD"
      while IFS= read -r group; do
        [ -z "$group" ] && continue
        aws ds-data add-group-member --directory-id "$DIRECTORY_ID" --group-name "$group" --member-name "$USERNAME" 2>/dev/null \
          || echo "warning: could not add $USERNAME to $group (already a member?)"
      done <<< "$GROUPS"
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue
    interpreter = ["/bin/bash", "-c"]
    environment = {
      AWS_REGION   = self.triggers.region
      DIRECTORY_ID = self.triggers.directory_id
      USERNAME     = self.triggers.username
    }
    command = "aws ds-data delete-user --directory-id \"$DIRECTORY_ID\" --sam-account-name \"$USERNAME\" || true"
  }

  depends_on = [null_resource.enable_data_access]
}
