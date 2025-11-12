# Generate random password for the app role
resource "random_password" "app_role" {
    length  = 32
    special = false
    
    lifecycle {
        ignore_changes = [
            length,
            special,
        ]
    }
}

# Create database for the app
resource "postgresql_database" "app_db" {
    name              = local.app_db_name
    owner             = postgresql_role.app_role.name
    template          = "template0"
    lc_collate        = "en_US.UTF-8"
    lc_ctype          = "en_US.UTF-8"
    connection_limit  = -1
    allow_connections = true
}

# Store app credentials in SSM Parameter Store
resource "aws_ssm_parameter" "app_db_credentials" {
    name        = local.parameter_name
    description = "Database credentials for ${var.app} in ${var.env}"
    type        = "SecureString"
    value = jsonencode({
        username = local.role_name
        password = random_password.app_role.result
        host     = data.aws_db_instance.croft.address
        port     = data.aws_db_instance.croft.port
        dbname   = local.app_db_name
    })
    
    tags = merge(local.tags, {
        Name = local.parameter_name
    })
}

# Create PostgreSQL role for the app
resource "postgresql_role" "app_role" {
    name     = local.role_name
    login    = true
    password = random_password.app_role.result
    
    # Can create databases
    create_database  = true
    connection_limit = -1
}
