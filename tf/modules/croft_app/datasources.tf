# Get the RDS security group
data "aws_security_group" "rds" {
    filter {
        name   = "tag:Name"
        values = ["croft-${var.env}"]
    }
}

# Generate IAM auth token for PostgreSQL provider
# IMPORTANT: Token must be generated with the real RDS endpoint, not the proxy
data "external" "db_auth_token" {
  # Example invocation:
  # # AWS_PROFILE=missiontech-dev ./generate_auth_token.sh <<<'{"hostname":"croft-dev.<id>.us-east-1.rds.amazonaws.com","port":"5432","username":"croft","region":"us-east-1"}'
  program = ["${path.module}/generate_auth_token.sh"]

  query = {
    hostname = local.db_endpoint
    port     = local.db_endpoint_port
    username = local.admin_username
    region   = data.aws_region.current.name
  }
}

# Get RDS instance details
data "aws_db_instance" "croft" {
  db_instance_identifier = "croft-${var.env}"
}

# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get private hosted zone for internal DNS
data "aws_ssm_parameter" "private_hosted_zone_id" {
    name = "/coreinfra/shared/private_hosted_zone_id"
}

data "aws_route53_zone" "private" {
    zone_id = data.aws_ssm_parameter.private_hosted_zone_id.value
}