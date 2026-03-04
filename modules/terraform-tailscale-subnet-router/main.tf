# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_net
}

resource "aws_launch_template" "tailscale" {
  name_prefix   = "tailscale-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  network_interfaces {
    associate_public_ip_address = var.public_ip_enabled
    security_groups             = [aws_security_group.tailscale_node.id]
  }

  dynamic "iam_instance_profile" {
    for_each = local.create_instance_profile ? [1] : []
    content {
      name = aws_iam_instance_profile.tailscale[0].name
    }
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "tailscale-${random_string.random_suffix.result}"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tailscale" {
  name                = "tailscale-asg-${random_string.random_suffix.result}"
  vpc_zone_identifier = [var.ts_router_subnet_id]
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.tailscale.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Name = "tailscale-${random_string.random_suffix.result}" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "tailscale_tailnet_key" "new" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 86400
  description   = "aws router key"

  lifecycle {
    ignore_changes = [expiry]
  }
}

resource "tailscale_acl" "main" {
  count                      = var.refresh_tailscale_main_acl ? 1 : 0
  overwrite_existing_content = true
  acl = var.tailscale_acl_content != "" ? var.tailscale_acl_content : templatefile("${path.module}/tailscale_acl.json.tpl", {
    tailscale_tag = var.tailscale_tag
  })
}
