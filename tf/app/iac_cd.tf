# IAC (infrastructure-as-code) ci/cd

module "hoist_github_ci" {
  # source = "../../../hoist/tf/modules/github_ci"
  source = "github.com/Mission-Tech/hoist//tf/modules/github_ci?ref=github_ci/v0.0.1"
  app        = local.app
  env = var.env
  org        = var.org
  repo       = local.repo
  tags = local.tags

  github_org = var.github_org
}

module "hoist_iac_cd_tf_runner" {
  # source = "../../../hoist/tf/modules/iac_cd/tf_runner"
  source = "github.com/Mission-Tech/hoist//tf/modules/iac_cd/tf_runner?ref=iac_cd/v0.0.7"
  app        = local.app
  env                           = var.env
  org        = var.org
  repo = local.repo
  tags = local.tags


  opentofu_version              = var.opentofu_version
  tools_account_id              = var.tools_account_id
  tools_codepipeline_role_arn   = local.conventional_tools_codepipeline_role_arn
  enable_auto_apply             = var.env != "prod"  # Enable for dev, disable for prod

  # Pass terraform variables needed by this environment
  tfvars = {
    org            = var.org
    env            = var.env
    aws_account_id = var.aws_account_id
    github_org     = var.github_org
    # Pass the tools_account_id for dev/prod environments
    tools_account_id = var.tools_account_id
    opentofu_version = var.opentofu_version
  }

  # No sensitive variables for dev/prod environments currently
  tfvars_sensitive = {}

  # Root module directory for dev/prod environments
  root_module_dir = "tf/app"
}
