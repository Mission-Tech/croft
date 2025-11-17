variable "env" {
  description = "Name of the environment (dev or prod)"
  type        = string
}

variable "org" {
  description = "Name of the prg (e.g. missiontech)"
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
    app : local.app
    env : var.env
    org : var.org
    repo : var.repo
  })
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

variable "tf_runner_security_group_id" {
  description = "Security group ID of the terraform runner (from iac_cd module). Required for bootstrap process to grant rds_iam role."
  type        = string
}