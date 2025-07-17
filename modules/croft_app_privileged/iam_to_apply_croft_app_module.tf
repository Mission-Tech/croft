# IAM policy granting minimum permissions required to apply the croft_app module
# This policy allows apps to create security group rules for database access

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "croft_app_permissions" {
    # Allow reading security groups to find the RDS security group
    statement {
        sid    = "ReadSecurityGroups"
        effect = "Allow"
        actions = [
            "ec2:DescribeSecurityGroups"
        ]
        resources = ["*"]
    }
    
    # Allow creating and managing security group rules
    statement {
        sid    = "ManageSecurityGroupRules"
        effect = "Allow"
        actions = [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:DescribeSecurityGroupRules"
        ]
        resources = [
            # Only allow modifying security groups in the current region and account
            "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*"
        ]
        condition {
            test     = "StringEquals"
            variable = "ec2:ResourceTag/Name"
            values   = ["croft-${var.env}"]
        }
    }
    
    # Allow reading region information
    statement {
        sid    = "ReadRegion"
        effect = "Allow"
        actions = [
            "ec2:DescribeRegions"
        ]
        resources = ["*"]
    }
}

# Create the IAM policy
resource "aws_iam_policy" "croft_app_permissions" {
    name        = "${var.app}-${var.env}-croft-app-permissions"
    description = "Minimum permissions required to apply the croft_app module for ${var.app} in ${var.env}"
    policy      = data.aws_iam_policy_document.croft_app_permissions.json
    
    tags = {
        Name = "${var.app}-${var.env}-croft-app-permissions"
        app  = var.app
        env  = var.env
        org  = var.org
    }
}

# Attach the policy to the CI role
resource "aws_iam_role_policy_attachment" "croft_app_permissions" {
    role       = var.ci_assume_role_name
    policy_arn = aws_iam_policy.croft_app_permissions.arn
}