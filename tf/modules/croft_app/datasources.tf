# Get the RDS security group
data "aws_security_group" "rds" {
    filter {
        name   = "tag:Name"
        values = ["croft-${var.env}"]
    }
}

# Get the admin password from SSM Parameter Store
data "aws_ssm_parameter" "admin_password" {
  name = local.admin_password_parameter
}

# Get RDS instance details
data "aws_db_instance" "croft" {
  db_instance_identifier = "croft-${var.env}"
}