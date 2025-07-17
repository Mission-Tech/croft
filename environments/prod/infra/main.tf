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

locals {
    org = "missiontech"
    env = "prod"
    app = "croft"
    module = "infra"
}

module "croft_base" {
    source = "../../../modules/croft_base" # Uncomment for local development  
    # source = "github.com/Mission-Tech/croft//tf/modules/croft_base?ref=croft_base/v0.0.1"
    app    = local.app
    env    = local.env
    org    = local.org
}


