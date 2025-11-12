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

variable "ci_assume_role_name" {
    description = "Name of the CI role that needs ECR permissions attached"
    type        = string
}

variable "repo" {
  description = "The URL of the github repo managing this infrastructure"
  type        = string
}

variable tags {
  description = "Tags to apply to every resource"
  type = map(string)
}

locals {
  tags = merge(var.tags, {
    app: var.app
    env: var.env
    org: var.org
    repo: var.repo
  })
}
