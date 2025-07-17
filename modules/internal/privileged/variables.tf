variable "env" {
    description = "Environment name (dev, prod)"
    type        = string
}

variable "app" {
    description = "Application name"
    type        = string
    default     = "gometheus"
}

variable "additional_policy_arns" {
    description = "List of additional IAM policy ARNs to attach to the Lambda role"
    type        = list(string)
    default     = []
}

variable "aws_iam_openid_connect_provider_github_arn" {
    description = "The arn of the OIDC Github provider"
    type = string
}

variable "github_org" {
    description = "GitHub organization name"
    type        = string
}

