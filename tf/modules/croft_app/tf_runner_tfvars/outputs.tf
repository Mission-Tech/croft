# Module that provides terraform variables for apps using croft database
#
# This module has no dependencies and just outputs static configuration,
# allowing it to be used without creating circular dependencies.
#
# Usage in app's iac_cd.tf:
#   module "croft_tf_runner" {
#     source = "github.com/Mission-Tech/croft//tf/modules/tf_runner?ref=vX.X.X"
#   }
#
#   module "hoist_iac_cd_tf_runner" {
#     tfvars_plan_only  = module.croft_tf_runner.tfvars_plan_only
#     tfvars_apply_only = module.croft_tf_runner.tfvars_apply_only
#   }

output "tfvars_plan_only" {
  description = "Terraform variables to pass to hoist_iac_cd_tf_runner.tfvars_plan_only (uses read-only postgres user)"
  value = {
    postgres_username = local.conventional_postgres_plan_username
  }
}

output "tfvars_apply_only" {
  description = "Terraform variables to pass to hoist_iac_cd_tf_runner.tfvars_apply_only (uses admin postgres user)"
  value = {
    postgres_username = local.conventional_postgres_plan_username
  }
}
