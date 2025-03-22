This Terraform module provisions an Amazon S3 bucket configured as a website that's only accessible through a VPC endpoint. It implements a secure access pattern for internal web content by restricting access to traffic from a specified VPC endpoint.
Features

Creates an S3 bucket configured for website hosting
Sets up a VPC endpoint for S3 with interface type
Blocks all public access to the S3 bucket
Configures least privilege permissions via bucket policy
Uploads website content from a local directory
Optional versioning for the S3 bucket
Optional access logging
Proper MIME type configuration for uploaded files
Consistent tagging across all resources

Usage:

**module "internal_website" {
  source = "github.com/edwardboucher/terra_reform/modules/s3_website_internal"

  environment    = "dev"
  vpc_id         = "vpc-0abc123def456789"
  bucket_prefix  = "internal-docs"
  
  subnet_configurations = [
    {
      ipv4      = "10.1.64.6"
      subnet_id = "subnet-0abc123def456789"
    },
    {
      ipv4      = "10.1.68.6"
      subnet_id = "subnet-0def456789abc123"
    }
  ]

  content_directory = "website-content/"
  enable_versioning = true
  enable_logging    = true
  region            = "us-east-1"

  tags = {
    Project     = "Internal Documentation"
    Department  = "Engineering"
    Owner       = "Infrastructure Team"
  }
}**

Example Project Structure

├── main.tf
├── variables.tf
├── outputs.tf
└── website-content/
    ├── index.html
    ├── error.html
    ├── css/
    │   └── styles.css
    ├── js/
    │   └── main.js
    └── images/
        └── logo.png
        
Requirements
NameVersionterraform>= 1.0.0aws>= 4.0.0
Inputs
NameDescriptionTypeDefaultRequiredenvironmentEnvironment name (e.g. dev, prod, staging)string"dev"novpc_idID of the VPC where the S3 endpoint will be createdstringn/ayessecurity_group_idSecurity group ID to be associated with the VPC endpointstringn/ayessubnet_configurationsList of subnet configurations for the VPC endpointlist(object)n/ayesbucket_prefixPrefix for the S3 bucket namestringn/ayescontent_directoryLocal directory containing files to upload to S3string"myfiles/"noenable_versioningEnable versioning for the S3 bucketbooltruenoenable_loggingEnable access logging for the S3 bucketbooltruenoregionAWS region for the S3 service endpointstring"us-east-1"notagsCommon tags to apply to all resourcesmap(string){}no
Outputs
NameDescriptionbucket_nameName of the created S3 bucketbucket_arnARN of the created S3 bucketbucket_regional_domain_nameRegional domain name of the S3 bucketwebsite_endpointWebsite endpoint URLvpc_endpoint_idID of the VPC endpoint for S3vpc_endpoint_dns_entriesDNS entries for the VPC endpoint
Complete Example with AWS VPC and VPC Endpoint
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create subnets
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main-subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "main-subnet-2"
  }
}

# Use the S3 Internal Website module
module "internal_docs_website" {
  source = "./modules/s3-internal-website"

  environment      = "dev"
  vpc_id           = aws_vpc.main.id
  bucket_prefix    = "internal-docs"
  
  subnet_configurations = [
    {
      ipv4      = "10.0.1.10"
      subnet_id = aws_subnet.subnet1.id
    },
    {
      ipv4      = "10.0.2.10"
      subnet_id = aws_subnet.subnet2.id
    }
  ]

  content_directory = "website-content/"
  enable_versioning = true
  enable_logging    = true
  
  tags = {
    Project     = "Internal Documentation"
    Department  = "Engineering"
    Owner       = "Infrastructure Team"
  }
}

output "website_endpoint" {
  value = module.internal_docs_website.website_endpoint
  description = "S3 website endpoint URL"
}

output "vpc_endpoint_dns" {
  value = module.internal_docs_website.vpc_endpoint_dns_entries
  description = "VPC endpoint DNS entries"
}
Notes

This module creates resources that may incur AWS charges
The S3 bucket will only be accessible through the VPC endpoint
Make sure the content directory contains at least an index.html file
This module does not create the VPC, subnets, or security groups - those must be provided as inputs