# main.tf
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
  }
  
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  # Calculate subnet configurations with dynamic IP addresses where not specified
  subnet_configs = [
    for idx, config in var.subnet_configurations : {
      subnet_id = config.subnet_id
      ipv4      = config.ipv4 != null ? config.ipv4 : cidrhost(data.aws_subnet.endpoint_subnets[idx].cidr_block, 10)
    }
  ]
}



# Create a VPC endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    #var.security_group_id
    aws_security_group.s3_endpoint_sg.id
  ]

  # dynamic "subnet_configuration" {
  #   for_each = var.subnet_configurations
  #   content {
  #     ipv4      = subnet_configuration.value.ipv4
  #     subnet_id = subnet_configuration.value.subnet_id
  #   }
  # }

  dynamic "subnet_configuration" {
  for_each = local.subnet_configs
  content {
    ipv4      = subnet_configuration.value.ipv4
    subnet_id = subnet_configuration.value.subnet_id
  }
}
  
  # Using subnet_configurations instead of subnet_ids
  private_dns_enabled = false
  tags = merge(
    local.common_tags,
    {
      Name = "app-vpce-s3-int-${var.environment}"
      Description = "VPC Endpoint for S3 with interface type"
    }
  )
}

# Create a security group for the S3 endpoint
resource "aws_security_group" "s3_endpoint_sg" {
  name        = "${var.bucket_prefix}-s3-endpoint-sg-${var.environment}"
  description = "Security group for S3 VPC endpoint - managed by Terraform"
  vpc_id      = var.vpc_id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.bucket_prefix}-s3-endpoint-sg-${var.environment}"
      Description = "Security group for S3 VPC endpoint"
    }
  )
}

# Create an S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket        = "${var.bucket_prefix}-${var.environment}"
  force_destroy = true
  tags = merge(
    local.common_tags,
    {
      Name = "${var.bucket_prefix}-${var.environment}"
      Description = "S3 bucket for hosting internal website content"
    }
  )
}

# Configure bucket versioning
resource "aws_s3_bucket_versioning" "website_bucket_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.website_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure bucket logging
resource "aws_s3_bucket_logging" "website_bucket_logging" {
  count         = var.enable_logging ? 1 : 0
  bucket        = aws_s3_bucket.website_bucket.id
  target_bucket = aws_s3_bucket.website_bucket.id
  target_prefix = "access-logs/"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "website_bucket_public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure website hosting
resource "aws_s3_bucket_website_configuration" "website_bucket_website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

# Apply bucket policy with least privilege
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.website_bucket.arn,
          "${aws_s3_bucket.website_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = [aws_vpc_endpoint.s3_endpoint.id]
          }
        }
      }
    ]
  })

  # Ensure the policy is applied after the public access block
  depends_on = [aws_s3_bucket_public_access_block.website_bucket_public_access_block]
}

# Upload files to S3
resource "aws_s3_object" "website_content" {
  for_each = fileset(var.content_directory, "**/*.*")

  bucket       = aws_s3_bucket.website_bucket.id
  key          = each.key
  source       = "${var.content_directory}${each.key}"
  content_type = lookup(
    local.mime_types,
    element(split(".", each.key), length(split(".", each.key)) - 1),
    "application/octet-stream" # Default content type if extension not found
  )
  etag = filemd5("${var.content_directory}${each.key}")

  # Add conditional tagging for objects
  tags = merge(
    local.common_tags,
    {
      ContentType = lookup(
        local.mime_types,
        element(split(".", each.key), length(split(".", each.key)) - 1),
        "application/octet-stream"
      )
    }
  )
}

