# Security group rule to allow app to connect to database
resource "aws_security_group_rule" "app_to_rds" {
    type                     = "ingress"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    source_security_group_id = var.app_security_group_id
    security_group_id        = data.aws_security_group.rds.id
}