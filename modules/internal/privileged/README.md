# Privileged Infrastructure Module

This module contains infrastructure resources that require elevated permissions to create and manage.

## Important Access Control

**This infrastructure can ONLY be deployed by humans with appropriate AWS permissions.**

CI/CD pipelines do not have permissions to create or modify these resources. This is a security measure to ensure that sensitive resources like IAM roles and policies are only managed through manual, audited processes.

## Resources Created

- IAM Policy with application-specific permissions
- IAM Role for Lambda execution
- Role policy attachments

## Manual Deployment Required

To deploy this module:
1. Ensure you have appropriate AWS credentials configured
2. Run terraform commands manually from your local machine
3. Review all changes before applying
