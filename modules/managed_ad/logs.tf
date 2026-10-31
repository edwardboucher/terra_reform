resource "aws_cloudwatch_log_group" "directory" {
  count             = var.enable_log_forwarding ? 1 : 0
  name              = "/aws/directoryservice/${aws_directory_service_directory.this.id}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

data "aws_iam_policy_document" "directory_logs" {
  count = var.enable_log_forwarding ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.directory[0].arn}:*"]

    principals {
      type        = "Service"
      identifiers = ["ds.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "directory_logs" {
  count           = var.enable_log_forwarding ? 1 : 0
  policy_name     = "${var.name}-directory-log-policy"
  policy_document = data.aws_iam_policy_document.directory_logs[0].json
}

resource "aws_directory_service_log_subscription" "directory" {
  count          = var.enable_log_forwarding ? 1 : 0
  directory_id   = aws_directory_service_directory.this.id
  log_group_name = aws_cloudwatch_log_group.directory[0].name

  depends_on = [aws_cloudwatch_log_resource_policy.directory_logs]
}
