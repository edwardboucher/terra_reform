
#The commands below are used to build and push a docker image of the application in the app folder
locals {
  docker_prune_command              = "docker system prune --all --force"
  docker_login_command              = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  docker_build_command              = "docker build ${var.docker_build_dir} -t local:${var.image_name}"
  docker_tag_command                = "docker tag local:${var.image_name} ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr.name}:${var.image_name}"
  docker_push_command               = "docker push ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr.name}:${var.image_name}"
}

#get app code from local source if git and s3 is not desined; app must be in zip format if s3 is used
resource "null_resource" "fetch_code" {
  provisioner "local-exec" {
    command = <<EOT
    if [ "${var.app_source_type}" == "git" ]; then
      git clone --branch ${var.git_branch} ${var.app_source_path} ${var.docker_build_dir}
    elif [ "${var.app_source_type}" == "s3" ]; then
      aws s3 cp s3://${var.s3_bucket}/${var.s3_key} app_code.zip
      unzip app_code.zip -d ${var.docker_build_dir}
    else
      cp -r ${var.app_source_path} ${var.docker_build_dir}
    fi
    EOT
  }
}

###modification of any local files before building
# Save file 01
resource "local_file" "html_image" {
  filename = "${path.module}/app_computer_demo/image/index.html"
  content  = templatefile("${path.module}/html_image.tpl", {
      dns_endpoint = module.demo_dns_record.record_fqdn
  })
}

# Save file 02
resource "local_file" "html_static" {
  filename = "${path.module}/app_computer_demo/image/static_content/index.html"
  content  = templatefile("${path.module}/html_static.tpl", {
      dns_endpoint = module.demo_dns_record.record_fqdn
  })
}

#This resource cleans up docker
# resource "null_resource" "docker_prune" {
#     provisioner "local-exec" {
#         command                     = local.docker_prune_command
#     }
#     triggers = {
#         "run_at"                    = timestamp()
#     }
#     depends_on                      = [ aws_ecr_repository.ecr ]
# }

#This resource authenticates you to the ECR service
resource "null_resource" "docker_login" {
    provisioner "local-exec" {
        command                     = local.docker_login_command
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ aws_ecr_repository.ecr,local_file.html_static,local_file.html_image ]
}

#This resource builds the docker image from the Dockerfile in the app folder
resource "null_resource" "docker_build" {
    provisioner "local-exec" {
        command                     = local.docker_build_command
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_login ]
}

#This resource tags the image 
resource "null_resource" "docker_tag" {
    provisioner "local-exec" {
        command                     = local.docker_tag_command
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_build ]
}

#This resource pushes the docker image to the ECR repo
resource "null_resource" "docker_push" {
    provisioner "local-exec" {
        command                     = local.docker_push_command
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_tag ]
}
