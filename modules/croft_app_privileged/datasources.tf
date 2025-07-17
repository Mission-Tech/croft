data "aws_region" "current" {}

# Get the admin password from SSM Parameter Store
data "aws_ssm_parameter" "admin_password" {
    name = local.admin_password_parameter
}

# Get RDS instance details
data "aws_db_instance" "croft" {
    db_instance_identifier = "croft-${var.env}"
}