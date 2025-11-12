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

variable tags {
  description = "Tags to apply to every resource"
  type = map(string)
}

locals {
  tags = merge(var.tags, {
    app: local.app
    env: var.env
    org: var.org
    repo: var.repo
  })
}