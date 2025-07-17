data "aws_region" "current" {}

# Get the RDS security group
data "aws_security_group" "rds" {
    filter {
        name   = "tag:Name"
        values = ["croft-${var.env}"]
    }
}