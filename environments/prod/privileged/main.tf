terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
    backend "s3" {
        bucket         = "coreinfra-tfstate-${local.org}-${local.env}"
        key            = "${local.app}/${local.module}/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "coreinfra-tfstate-lock-${local.org}-${local.env}"
    }
}

provider "aws" {}

data "aws_region" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
    org = "missiontech"
    env = "prod"
    app = "croft"
    module = "privileged"
}

# Any privileged infra that this app in particular needs
module privileged {
    source      = "../../../modules/internal/privileged"
    env = local.env
    app    = local.app
    aws_iam_openid_connect_provider_github_arn = data.aws_iam_openid_connect_provider.github.arn
    github_org = "mission-tech"
}

# The privileged infrastructure to apply the croft_base module
module "croft_base_privileged" {
    source = "../../../modules/croft_base_privileged" # Uncomment for local development  
    # source = "github.com/Mission-Tech/croft//tf/modules/croft_base_privileged?ref=croft_base_privileged/v0.0.1"
    app    = local.app
    env    = local.env
    ci_assume_role_name = module.privileged.github_deploy_role_name
}

// Base permissions for every app (e.g. ability to apply terraform)
module "hoist_base_meta" {
    # source = "../../../../../hoist/tf/modules/base_meta" # Uncomment below for local development  
    source = "github.com/Mission-Tech/hoist//tf/modules/base_meta?ref=base_meta/v0.1.9"
    app    = local.app
    env    = local.env
    org = "missiontech"
    tfstate_access_role_name = module.privileged.github_deploy_role_name
}

