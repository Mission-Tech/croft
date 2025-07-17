data "aws_organizations_organization" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_deploy" {
    name = "${var.app}-${var.env}-ci"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Federated = var.aws_iam_openid_connect_provider_github_arn
                },
                Action = "sts:AssumeRoleWithWebIdentity",
                Condition = {
                    StringEquals = {
                        "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
                        "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.app}:environment:${var.env}"
                    }
                }
            }
        ]
    })

    tags = {
        Name        = "${var.app}-${var.env}-ci"
        Description = "GitHub-assumable CI role for ${var.app} in ${var.env} environment"
        Application = var.app
        Environment = var.env
    }
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
    for_each   = toset(var.additional_policy_arns)
    policy_arn = each.value
    role       = aws_iam_role.github_deploy.name
}
