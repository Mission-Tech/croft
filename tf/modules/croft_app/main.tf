# Security group rule to allow app to connect to database
resource "aws_security_group_rule" "app_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.app_security_group_id
  security_group_id        = data.aws_security_group.rds.id
}

# Security group rule to allow terraform runner (CodeBuild) to connect to database
# This is required for terraform to create per-app databases and roles via the postgresql provider
resource "aws_security_group_rule" "tf_runner_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.tf_runner_security_group_id
  security_group_id        = data.aws_security_group.rds.id
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

# Create PostgreSQL role for the app (IAM authentication, no password)
resource "postgresql_role" "app_role" {
  name  = local.role_name
  login = true

  # Can create databases
  create_database  = true
  connection_limit = -1
}

# Grant rds_iam role to enable IAM authentication
resource "postgresql_grant_role" "app_role_iam" {
  role       = local.role_name
  grant_role = "rds_iam"

  depends_on = [postgresql_role.app_role]
}

# IAM policy to allow RDS IAM database authentication
resource "aws_iam_role_policy" "rds_iam_connect" {
  name = "rds-iam-connect-${var.app}-${var.env}"
  role = var.app_iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${data.aws_db_instance.croft.resource_id}/${local.role_name}"
        ]
      }
    ]
  })
}
