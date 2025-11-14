output "db_host" {
    description = "Database host (internal DNS name)"
    value       = local.db_dns_name
}

output "db_port" {
    description = "Database port"
    value       = data.aws_db_instance.croft.port
}

output "db_username" {
    description = "Database username for the app"
    value       = local.role_name
}

output "db_name" {
    description = "Database name for the app"
    value       = local.app_db_name
}