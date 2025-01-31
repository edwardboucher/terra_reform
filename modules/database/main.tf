resource "aws_db_instance" "database" {
  db_name           = var.database_name
  identifier        = var.database_name
  engine            = var.database_type_engine
  engine_version    = data.aws_rds_engine_version.parse.id
  instance_class    = var.instance_class
  
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  username = var.username
  password = var.password

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.base.id

  # Best practices
  backup_retention_period = 7
  multi_az                = true
  skip_final_snapshot     = true
}

resource "aws_db_subnet_group" "base" {
  name       = "main"
  subnet_ids = [var.db_subnet1_id, var.db_subnet2_id]

  tags = {
    Name = "db_subnet_group"
  }
}