# IAM policy granting permissions required to apply the croft_base module
# This policy allows creating and managing the shared RDS instance and related resources

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "croft_base_permissions" {
    # Allow reading AWS resources needed for data sources
    statement {
        sid    = "ReadAWSResources"
        effect = "Allow"
        actions = [
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeVpcs",
            "ec2:DescribeSubnets",
            "rds:DescribeDBInstances",
            "rds:DescribeDBSubnetGroups"
        ]
        resources = ["*"]
    }
    
    # Allow managing RDS resources
    statement {
        sid    = "ManageRDSResources"
        effect = "Allow"
        actions = [
            "rds:CreateDBInstance",
            "rds:ModifyDBInstance",
            "rds:DeleteDBInstance",
            "rds:CreateDBSubnetGroup",
            "rds:ModifyDBSubnetGroup",
            "rds:DeleteDBSubnetGroup",
            "rds:AddTagsToResource",
            "rds:RemoveTagsFromResource",
            "rds:ListTagsForResource"
        ]
        resources = [
            "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.app}-${var.env}",
            "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:subgrp:${var.app}-${var.env}"
        ]
    }
    
    # Allow managing security groups
    statement {
        sid    = "ManageSecurityGroups"
        effect = "Allow"
        actions = [
            "ec2:CreateSecurityGroup",
            "ec2:DeleteSecurityGroup",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:DescribeSecurityGroupRules",
            "ec2:CreateTags",
            "ec2:DeleteTags"
        ]
        resources = [
            "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*"
        ]
        condition {
            test     = "StringEquals"
            variable = "ec2:ResourceTag/Name"
            values   = ["${var.app}-${var.env}"]
        }
    }
    
    # Allow managing SSM parameters for passwords
    statement {
        sid    = "ManageSSMParameters"
        effect = "Allow"
        actions = [
            "ssm:PutParameter",
            "ssm:GetParameter",
            "ssm:DeleteParameter",
            "ssm:AddTagsToResource",
            "ssm:RemoveTagsFromResource"
        ]
        resources = [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/apps/${var.app}-${var.env}/*"
        ]
    }
    
    # Allow using random provider (no specific permissions needed, but for completeness)
    statement {
        sid    = "RandomProvider"
        effect = "Allow"
        actions = [
            "kms:Decrypt",
            "kms:GenerateDataKey"
        ]
        resources = [
            "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
        ]
        condition {
            test     = "StringEquals"
            variable = "kms:ViaService"
            values   = ["ssm.${data.aws_region.current.name}.amazonaws.com"]
        }
    }
}

# Create the IAM policy
resource "aws_iam_policy" "croft_base_permissions" {
    name        = "${var.app}-${var.env}-croft-base-permissions"
    description = "Permissions required to apply the croft_base module for ${var.app} in ${var.env}"
    policy      = data.aws_iam_policy_document.croft_base_permissions.json
    
    tags = {
        Name = "${var.app}-${var.env}-croft-base-permissions"
        app  = var.app
        env  = var.env
    }
}

# Attach the policy to the CI role
resource "aws_iam_role_policy_attachment" "croft_base_permissions" {
    role       = var.ci_assume_role_name
    policy_arn = aws_iam_policy.croft_base_permissions.arn
}