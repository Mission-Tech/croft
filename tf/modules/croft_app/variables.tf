variable "app" {
  description = "Name of the application"
  type        = string
}

variable "env" {
  description = "Name of the environment (dev or prod)"
  type        = string
}

variable "org" {
  description = "Name of the organization (e.g. missiontech)"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID for the app (ECS service, Lambda, etc.) that needs database access"
  type        = string
}

variable "app_iam_role_name" {
  description = "IAM role name for the app (ECS task role, Lambda execution role, etc.) that needs database access"
  type        = string
}

variable "repo" {
  description = "The URL of the github repo managing this infrastructure"
  type        = string
}

variable "tags" {
  description = "Tags to apply to every resource"
  type        = map(string)
}

locals {
  tags = merge(var.tags, {
    app : var.app
    env : var.env
    org : var.org
    repo : var.repo
  })
}

variable "db_host" {
  description = "Database host that terraform can access (likely through the bastion proxy)"
  type        = string
  default     = null # Actually defaults to the RDS private vpc host via a datasource
}

variable "db_port" {
  description = "Database port that terraform can access (likely through the bastion proxy)"
  type        = number
  default     = null # Actually defaults to the RDS instance port via a datasource
}

variable "tf_runner_security_group_id" {
  description = "Security group ID of the terraform runner (from iac_cd module). Required for bootstrap process to grant rds_iam role and for terraform to create per-app databases."
  type        = string
}