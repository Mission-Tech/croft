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
variable "tools_account_id" {
  description = "AWS Account ID for the tools account"
  type        = string
}

variable "opentofu_version" {
  description = "Version of OpenTofu to use in Lambda functions"
  type        = string
}

variable "db_proxy_host" {
  description = "Database host for terraform to connect through. Defaults to actual RDS endpoint. Set to '127.0.0.1' for local development with bastion proxy."
  type        = string
  default     = null
}

variable "db_proxy_port" {
  description = "Database port for terraform to connect through. Defaults to actual RDS port. Set to custom port for local development with bastion proxy."
  type        = number
  default     = null
}

