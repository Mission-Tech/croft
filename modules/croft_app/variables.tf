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

