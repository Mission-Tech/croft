variable "aws_account_id" {
  description = "The ID of this aws account"
  type        = string
}

variable "aws_region" {
  description = "AWS Region to use"
  default     = "us-east-1"
}

variable "env" {
  description = "The name of the environment (e.g., dev, prod)"
  type        = string
}

variable "org" {
  description = "The name of your organization (e.g., missiontech)"
  type        = string
}

variable "github_org" {
  description = "The name of your github organization (e.g., mission-tech)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to every resource"
  default     = {}
  type        = map(string)
}

locals {
  tags = merge(var.tags, {
    app : local.app
    env : var.env
    org : var.org
    repo : local.repo
  })
}

# Cross-account ID variables
variable "dev_account_id" {
  description = "AWS Account ID for the dev account"
  type        = string
}

# Cross-account ID variables
variable "prod_account_id" {
  description = "AWS Account ID for the prod account"
  type        = string
}

variable "slack_cd_webhook_url" {
  description = "Slack webhook URL for CD notifications"
  type        = string
  sensitive   = true
}

variable "opentofu_version" {
  description = "Version of OpenTofu to use in Lambda functions"
  type        = string
}
