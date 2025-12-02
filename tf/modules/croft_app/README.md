# croft_app

A terraform module that individual apps will instantiate to be able to use the croft database.

## Basic Usage

```hcl
module "croft_database" {
  source = "github.com/Mission-Tech/croft//tf/modules/croft_app?ref=croft_app/v0.0.1"

  app    = local.app
  env    = var.env
  org    = var.org
  repo   = local.repo
  tags   = local.tags

  app_security_group_id = module.hoist_lambda.app_security_group_id
  app_iam_role_name     = module.hoist_lambda.app_iam_role_name

  tf_runner_security_group_id = module.hoist_iac_cd.tf_runner.security_group_id
}
```

## Optional: Database Migrations Support

If you have a separate process (like a CodeBuild job or ECS task) that runs database migrations during deployment, you can grant it the necessary permissions:

```hcl
module "croft_database" {
  source = "github.com/Mission-Tech/croft//tf/modules/croft_app?ref=croft_app/v0.0.1"

  # ... basic variables ...

  # Optional migrations support
  migrations_runner_security_group_id = module.migrations_job.security_group_id
  migrations_iam_role_name            = module.migrations_job.iam_role_name
}
```

This will:
- Add security group rules to allow the migrations runner to connect to RDS
- Grant the migrations IAM role permission to authenticate to the database

