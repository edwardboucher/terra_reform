locals {
  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "png"  = "image/png"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
    "wav"  = "audio/wav"
    "jpg"  = "image/jpeg"
    "yaml" = "text/yaml"
    "yml" = "text/yaml"
    "sh"  = "text/x-shellscript"
    "template"  = "text/template"
    "md"  = "text/md"
    "py"  = "application/x-python-code"
  }
}

resource "aws_s3_bucket" "b" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  tags = {
    Name        = "guacamole_source_${random_string.seed_string.result}"
    Environment = "dev"
  }
}

# #move all files to s3 with folders
resource "aws_s3_object" "content" {
  for_each = fileset("${path.module}/myfiles/push-to-docker-host/", "**/*.*")

  bucket       = aws_s3_bucket.b.id
  key          = each.key
  source       = "${path.module}/myfiles/push-to-docker-host/${each.key}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.key), length(split(".", each.key)) - 1))
  etag         = filemd5("${path.module}/myfiles/push-to-docker-host/${each.key}")
}

resource "aws_iam_role" "s3_role_guac" {
  name               = "guac_role"
  assume_role_policy = data.aws_iam_policy_document.guac_role_assume_role_policy.json

  # Combined Inline Policy for EC2 Describe and SSM Get Permissions
  inline_policy {
    name = "guac_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetBucketLocation",
            "s3:ListAllMyBuckets"
            ]
          Effect = "Allow",
          Resource = "arn:aws:s3:::*"
        },
        {
          Action = [
            "s3:*"
            ]
          Effect = "Allow",
          Resource = [ 
            "${aws_s3_bucket.b.arn}",
            "${aws_s3_bucket.b.arn}/*" 
          ]
        },
        {
          Effect   = "Allow"
          Action   = [
            "ec2:Describe*",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath"
          ]
          Resource = [
            "*",
            "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/guac/*"  # Adjust this as needed
          ]
        },
      ]
    })
  }
}

# Assume Role Policy for guac
data "aws_iam_policy_document" "guac_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["*"]  # Replace with specific role/user ARN if needed for security
    }
  }
}

# Instance Profile for EC2 Instances
resource "aws_iam_instance_profile" "guac_profile" {
  name = "guac_profile"
  role = aws_iam_role.s3_role_guac.name
}

##############################################

resource "random_string" "db_pass" {
  length = 16
  special = true
  upper  = true
  lower = true
  numeric = true
}

locals {
 template_vars = { 
    db_pass = random_string.db_pass.result
    guac_admin_username = var.guac_admin_username
    }
}

resource "aws_s3_object" "compose-yaml" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
  key    = "docker-compose.yml"
  content = templatefile("${path.module}/myfiles/docker-compose.yml.tpl", local.template_vars)
  depends_on = [aws_s3_object.content]
}