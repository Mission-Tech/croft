# Conventional names and settings based on croft_base module
locals {
    # Database connection info
    admin_db_name = "croft_${var.env}"  # Admin database for creating new databases
    app_db_name = "${var.app}_${var.env}"  # App-specific database
    db_host = coalesce(var.db_host, data.aws_db_instance.croft.address)
    db_port = coalesce(var.db_port, data.aws_db_instance.croft.port)
    
    # Admin credentials location (matches croft_base SSM parameter)
    admin_password_parameter = "/apps/croft-${var.env}/postres_admin_password"
    admin_username = "croft"
    
    # Per-app tenant naming
    role_name = "${var.app}_${var.env}"
    
    # SSM Parameter naming
    parameter_name = "/apps/${var.app}-${var.env}/croft_db_credentials"
}
