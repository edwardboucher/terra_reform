#EXAMPLE 01:
module "ecs_deploy" {
  source = "github.com/edwardboucher/terra_reform/modules/ecs"
  app_name  = "projectdemo001"
  environment = "dev"
  region = "us-east-1"
  ecr_url = "xxxxxxxxxxx.dkr.ecr.eu-central-1.amazonaws.com/workshop"
  log_bucket_name = "alb_log_bucket"
  container_ports = 8080
  image_name = "anthropic-quickstarts-computer-use-demo-latest"
  container_env_name = "APP_API_KEY"
  container_env_value = "api-keyxxxxxxxx"
  container_volume_path "/home/computeruse/.anthropic"
  aws_subnet_public_1_id = subnet1_id
  aws_subnet_public_2_id = subnet2_id
  custom_ingress_cidr = false
}

#EXAMPLE 02
module "ecs_application" {
  source = "github.com/edwardboucher/terra_reform/modules/ecs"

  # Required variables
  app_name    = "myapp"
  environment = "dev"
  region      = "us-east-1"
  
  # Container configuration
  ecr_url     = "xxxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/myapp"
  image_name  = "myapp-image-latest"
  
  # Networking
  aws_subnet_public_1_id = "subnet-xxxxxxxx"  # First public subnet
  aws_subnet_public_2_id = "subnet-yyyyyyyy"  # Second public subnet

  # Container environment
  container_env_name  = "APP_API_KEY"
  container_env_value = "your-api-key"  # Consider using SSM Parameter Store
}

#NOTES:
exist of env for containers?
multiple ingress rules
multiple ports