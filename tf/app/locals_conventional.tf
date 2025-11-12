locals {

  # created by hoist's iac_cd module, instantiated in the tools account
  conventional_tools_codepipeline_role_arn = "arn:aws:iam::${var.tools_account_id}:role/${var.org}-${local.app}-tools-codepipeline"
}
