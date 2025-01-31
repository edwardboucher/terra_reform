output "database_endpoint" {
  description = "Connection endpoint for the database with :port"
  value       = aws_db_instance.database.endpoint
}

output "database_address" {
  description = "Connection endpoint for the database without :port"
  value       = aws_db_instance.database.address
}

output "database_port" {
  description = "Port the database is listening on"
  value       = aws_db_instance.database.port
}

output "database_name" {
  description = "namesake"
  value       = aws_db_instance.database.db_name
}

output "database_username" {
  description = "User for the database"
  value       = aws_db_instance.database.username
}

output "database_password" {
  description = "User for the database"
  value       = aws_db_instance.database.password
}