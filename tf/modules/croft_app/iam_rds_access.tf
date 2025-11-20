# Grant terraform plan and apply roles permission to connect to RDS
# This allows the postgres provider to generate IAM auth tokens for database access

# IAM policy to allow terraform plan role to connect as croft_plan (read-only)
resource "aws_iam_role_policy" "plan_rds_connect" {
  count = var.tf_plan_role_name != null ? 1 : 0

  name = "rds-connect-croft-plan"
  role = var.tf_plan_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${data.aws_db_instance.croft.resource_id}/croft_plan"
        ]
      }
    ]
  })
}

# IAM policy to allow terraform apply role to connect as croft_apply (admin)
resource "aws_iam_role_policy" "apply_rds_connect" {
  count = var.tf_apply_role_name != null ? 1 : 0

  name = "rds-connect-croft-apply"
  role = var.tf_apply_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${data.aws_db_instance.croft.resource_id}/croft_apply"
        ]
      }
    ]
  })
}
