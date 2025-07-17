output "github_deploy_role_name" {
    description = "Name of the GitHub deploy role"
    value       = aws_iam_role.github_deploy.name
}
