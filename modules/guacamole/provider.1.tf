terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# No provider block: inherits the caller's aws provider (and its default_tags).
# var.region is still used by connections_sync.tf and the IAM policy.