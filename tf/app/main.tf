terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "${var.org}-coreinfra-${var.env}-${var.aws_account_id}-tfstate"
    key            = "${local.app}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "${var.org}-coreinfra-${var.env}-tfstate-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  app  = "croft"
  repo = "https://github.com/${var.github_org}/${local.app}"
}

module "croft_base" {
  source = "../modules/croft_base"
  env    = var.env
  org    = var.org
  repo   = local.repo
  tags   = local.tags

  db_proxy_host = var.db_proxy_host
  db_proxy_port = var.db_proxy_port
}