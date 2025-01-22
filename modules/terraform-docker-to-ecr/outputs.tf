output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = var.create_ecr ? aws_ecr_repository.ecr_repo[0].name : data.aws_ecr_repository.existing_repo[0].name
}

output "ecr_repository_uri" {
  description = "The URI of the ECR repository"
  value       = var.create_ecr ? aws_ecr_repository.ecr_repo[0].repository_url : data.aws_ecr_repository.existing_repo[0].repository_url
}