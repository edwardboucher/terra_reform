output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = var.create_ecr ? aws_ecr_repository.ecr_repo[0].name : data.aws_ecr_repository.existing_repo[0].name
}

output "ecr_repository_uri" {
  description = "The URI of the ECR repository"
  value       = var.create_ecr ? aws_ecr_repository.ecr_repo[0].repository_url : data.aws_ecr_repository.existing_repo[0].repository_url
}

output "ecs_template_file" {
  description = "For future ECS useage"
  value       = templatefile("${path.module}/container_definition.tpl", {
      app_name          = var.app_name
      anthropic_api_key = var.anthopic_api_key
      repository_url = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr.name}:${var.image_name}"
      container_port = var.container_port
      efs_container_path = var.efs_container_map_path
  }
}