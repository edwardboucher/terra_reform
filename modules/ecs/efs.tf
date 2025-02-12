# EFS File System
resource "aws_efs_file_system" "app" {
  creation_token = "${var.app_name}-efs"
  encrypted      = true

  tags = {
    Name = "${var.app_name}-efs"
  }
}

# EFS Mount Targets (one per subnet)
resource "aws_efs_mount_target" "efs_mt_1" {
  file_system_id  = aws_efs_file_system.app.id
  subnet_id       = var.aws_subnet_public_1_id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "efs_mt_2" {
  file_system_id  = aws_efs_file_system.app.id
  subnet_id       = var.aws_subnet_public_2_id
  security_groups = [aws_security_group.efs.id]
}

# Add EFS access point
resource "aws_efs_access_point" "app" {
  file_system_id = aws_efs_file_system.app.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}