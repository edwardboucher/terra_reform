Terraform VPC Module
This module creates an AWS Virtual Private Cloud (VPC) with two public and two private subnets, an Internet Gateway for public subnet connectivity, and VPC Flow Logs for traffic monitoring.

Resources Created
VPC:

Creates a VPC with DNS support and hostnames enabled.
Subnets:

2 Public Subnets: Assigned public IPs and connected to the Internet Gateway.
2 Private Subnets: Reserved for internal resources.
Internet Gateway:

Provides internet access for resources in the public subnets.
Route Tables:

One route table for public subnets with a route to the Internet Gateway.
VPC Flow Logs:

Captures traffic flow for monitoring and troubleshooting. Logs are stored in a CloudWatch Log Group.
CloudWatch Log Group:

Stores VPC flow logs with a customizable retention period.
IAM Role:

Enables VPC Flow Logs to write to CloudWatch.

Usage Example
Create a main.tf file and use the module as follows:

module "vpc" {
  source = "github.com/edwardboucher/terra_reform/modules/vpc"
  public_subnet_count = 2
  private_subnet_count = 2
  region        = "us-east-1"
  vpc_cidr      = "10.0.0.0/16"
  name          = "my-vpc"
  tags          = { "Environment" = "Dev" }
  log_retention = 14
  usePrivateNAT = true
}

Run the following commands to deploy:

Initialize Terraform:

terraform init
Plan the Deployment:

terraform plan
Apply the Configuration:

terraform apply

Module Inputs
Variable	Type	Default	Description
vpc_cidr	string	N/A	CIDR block for the VPC.
subnet_prefix	number	4	Subnet prefix size for dividing the VPC CIDR.
name	string	N/A	Prefix for naming resources.
tags	map(string)	{}	Tags applied to all resources.
log_retention	number	7	Number of days to retain VPC flow logs in CloudWatch.

Module Outputs
Output	Description
vpc_id	The ID of the created VPC.
public_subnet_ids	The IDs of the created public subnets.
private_subnet_ids	The IDs of the created private subnets.


Next Steps for Expansion
Add NAT Gateway:

Enable internet access for private subnets using a NAT Gateway.
Support Multiple AZs:

Extend the module to deploy subnets across all available Availability Zones.
Custom Route Tables for Private Subnets:

Create separate route tables for private subnets for more granular control.
Add Security Groups:

Include default security groups for public and private resources.
Support Multiple Flow Log Destinations:

Extend Flow Logs to support S3 storage or other destinations.
Make Tags More Dynamic:

Allow user-defined tags to be applied at different resource levels.
Optimization Opportunities
Parameterize Resources: Add optional parameters for advanced features (e.g., enabling NAT Gateways or custom flow log destinations).
Add Lifecycle Policies: Manage resource updates or deletions using lifecycle settings.
Enhance Logging Options: Support JSON format and destination options for flow logs.
Cost Optimization: Include usage of free-tier friendly resources for testing environments.
Contributing
Feel free to raise issues or submit pull requests to enhance this module. Contributions are welcome!

License
This module is open-source and licensed under the MIT License.