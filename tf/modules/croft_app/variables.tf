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