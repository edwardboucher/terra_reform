# Re-syncs Guacamole connections onto the already-running guac-server1 via
# SSM RunCommand whenever var.guac_target_instances changes, without
# recreating the instance. guacdeploy.sh only runs guac_add_connections.sh
# once, at first boot (via user_data) — updating aws_s3_object.connections-json
# alone does not reach an instance that's already up, so this resource
# re-downloads connections.json and re-invokes the script over SSM.
# guac_add_connections.sh matches connections by name and is safe to re-run.
resource "null_resource" "sync_connections" {
  triggers = {
    connections_hash = md5(jsonencode(local.guac_connections))
    instance_id      = aws_instance.guac-server1.id
  }

  depends_on = [
    aws_s3_object.connections-json,
    aws_iam_role_policy_attachment.ssm_core,
    aws_instance.guac-server1,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      INSTANCE_ID="${aws_instance.guac-server1.id}"
      REGION="${var.region}"
      S3_URI="s3://${aws_s3_bucket.b.bucket}/connections.json"

      echo "Waiting for SSM registration on $INSTANCE_ID..."
      for i in $(seq 1 24); do
        STATUS=$(aws ssm describe-instance-information --region "$REGION" \
          --filters "Key=InstanceIds,Values=$INSTANCE_ID" \
          --query "InstanceInformationList[0].PingStatus" --output text 2>/dev/null || echo "None")
        if [ "$STATUS" = "Online" ]; then
          break
        fi
        sleep 5
      done

      # Built as a JSON params file (rather than "--parameters commands=...")
      # because the shell command below contains quotes that trip up the AWS
      # CLI's shorthand parameter parser.
      PARAMS_FILE=$(mktemp)
      trap 'rm -f "$PARAMS_FILE"' EXIT
      jq -n --arg cmd "cd /guacamole-docker-compose && aws s3 cp $S3_URI . && ./guac_add_connections.sh '${var.guac_admin_username}' '${var.guac_admin_password}' ./connections.json" \
        '{commands: [$cmd]}' > "$PARAMS_FILE"

      CMD_ID=$(aws ssm send-command --region "$REGION" \
        --instance-ids "$INSTANCE_ID" \
        --document-name "AWS-RunShellScript" \
        --parameters "file://$PARAMS_FILE" \
        --query "Command.CommandId" --output text)

      aws ssm wait command-executed --region "$REGION" --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" || true
      aws ssm get-command-invocation --region "$REGION" --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
        --query "{Status:Status,StdOut:StandardOutputContent,StdErr:StandardErrorContent}" --output json
    EOT
  }
}
