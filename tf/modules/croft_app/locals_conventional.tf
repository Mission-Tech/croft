# Conventional PostgreSQL usernames for terraform runners
# These must match the roles created in croft_base module's bootstrap script

locals {
  # Created in croft_base's grant_rds_iam_bootstrap.sh
  conventional_postgres_plan_username  = "croft_plan"  # Read-only user for terraform plan
  conventional_postgres_apply_username = "croft_apply" # Admin user for terraform apply
}
