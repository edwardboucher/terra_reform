# iam.tf

locals {
  create_instance_profile = var.iam_role != "" || var.enable_ssm
}

resource "aws_iam_role" "ssm" {
  count = var.enable_ssm && var.iam_role == "" ? 1 : 0
  name  = "tailscale-ssm-role-${random_string.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm && var.iam_role == "" ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "tailscale" {
  count = local.create_instance_profile ? 1 : 0
  name  = "tailscale-profile-${random_string.random_suffix.result}"
  # one() safely returns null if the SSM role list is empty (i.e., iam_role was provided instead)
  role  = var.iam_role != "" ? var.iam_role : one(aws_iam_role.ssm[*].name)

  tags = var.tags
}
