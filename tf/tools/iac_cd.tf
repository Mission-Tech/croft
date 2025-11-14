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

module "hoist_iac_cd" {
  # source = "../../../hoist/tf/modules/iac_cd"
  source = "github.com/Mission-Tech/hoist//tf/modules/iac_cd?ref=iac_cd/v0.0.8"
  app        = local.app
  org        = var.org
  repo = local.repo
  tags = local.tags

  ci_role_name = module.hoist_github_ci.ci_iam_role_name

  # Cross-account IDs
  dev_account_id  = var.dev_account_id
  prod_account_id = var.prod_account_id

  # CD configuration
  slack_cd_webhook_url = var.slack_cd_webhook_url
  opentofu_version     = var.opentofu_version
  github_org           = var.github_org
}
