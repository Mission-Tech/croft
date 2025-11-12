output "parameter_name" {
    description = "Name of the SSM parameter containing database credentials"
    value       = aws_ssm_parameter.app_db_credentials.name
}

output "parameter_arn" {
    description = "ARN of the SSM parameter containing database credentials"
    value       = aws_ssm_parameter.app_db_credentials.arn
}

output "db_username" {
    description = "Database username for the app"
    value       = local.role_name
}

output "db_name" {
    description = "Database name for the app"
    value       = local.app_db_name
}

output "db_connection_uri" {
    description = "PostgreSQL connection URI (use with parameter for credentials)"
    value       = "postgres://${data.aws_db_instance.croft.address}:${data.aws_db_instance.croft.port}/${local.app_db_name}"
    sensitive   = true
}