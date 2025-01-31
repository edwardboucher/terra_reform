# Flexible RDS Database Terraform Module

## Overview
This Terraform module creates a flexible Amazon RDS database with customizable configuration options.

## Features
- Support for multiple database engines
- Configurable instance and storage settings
- Secure credential management
- Multi-AZ deployment
- Automated backup configuration

## Requirements
- Terraform 1.0+
- AWS Provider

## Usage Examples

### Basic MySQL Database
```hcl
module "mysql_database" {
  source = "./rds-module"

  database_type     = "mysql"
  database_name     = "myapp-database"
  instance_class    = "db.t3.medium"
  allocated_storage = 50
  
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.database.id]
  subnet_group_name      = aws_db_subnet_group.private.name
}
```

### PostgreSQL with Custom Configuration
```hcl
module "postgresql_database" {
  source = "./rds-module"

  database_type     = "postgres"
  database_name     = "analytics-db"
  engine_version    = "13.7"
  instance_class    = "db.r5.large"
  allocated_storage = 200
  storage_type      = "io1"

  username = var.db_username
  password = var.db_password
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| database_type | Database engine type | string | "mysql" | No |
| database_name | Name of the database | string | - | Yes |
| engine_version | Database engine version | string | null | No |
| instance_class | RDS instance type | string | "db.t3.medium" | No |
| allocated_storage | Storage size in GB | number | 20 | No |
| username | Database master username | string | - | Yes |
| password | Database master password | string | - | Yes |

## Outputs

| Name | Description |
|------|-------------|
| database_endpoint | Connection endpoint for the database |
| database_port | Port the database is listening on |

## Security Considerations
- Always use secret management for credentials
- Limit security group access
- Enable encryption at rest

## Note
Ensure you have proper AWS credentials configured before applying this module.
