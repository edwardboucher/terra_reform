#################################################################################################
# This file describes the ECR resources: ECR repo, ECR policy, resources to build and push image
#################################################################################################

#Creation of the ECR repo
resource "aws_ecr_repository" "ecr" {
    name = "my-test-repo"
    image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }
  encryption_configuration {
    encryption_type = var.ecr_encryption_type
  }
}

#The ECR policy describes the management of images in the repo
# resource "aws_ecr_lifecycle_policy" "ecr_policy" {
#     repository                      = aws_ecr_repository.ecr.repository_url
#     policy                          = local.ecr_policy
#     depends_on = [ aws_ecr_repository.ecr ]
# }

# #This is the policy defining the rules for images in the repo
# locals {
#   ecr_policy = jsonencode({
#         "rules":[
#             {
#                 "rulePriority"      : 1,
#                 "description"       : "Expire images older than 14 days",
#                 "selection": {
#                     "tagStatus"     : "any",
#                     "countType"     : "sinceImagePushed",
#                     "countUnit"     : "days",
#                     "countNumber"   : 14
#                 },
#                 "action": {
#                     "type"          : "expire"
#                 }
#             }
#         ]
#     })
# }