variable "app" {
    description = "Name of the application"
    type        = string
}

variable "env" {
    description = "Name of the environment (e.g., dev, prod)"
    type        = string
}

variable "ci_assume_role_name" {
    description = "Name of the CI role that needs ECR permissions attached"
    type        = string
}
