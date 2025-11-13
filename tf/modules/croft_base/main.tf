# DB subnet group
resource "aws_db_subnet_group" "rds" {
    name       = "${local.app}-${var.env}"
    subnet_ids = local.private_subnet_ids

    tags = merge(local.tags, {
        Name = "${local.app}-${var.env}"
    })
}


# Security group for RDS
resource "aws_security_group" "rds" {
    name        = "${local.app}-${var.env}"
    description = "Allow DB access within VPC"
    vpc_id      = data.aws_vpc.main.id

    tags = merge(local.tags, {
        Name = "${local.app}-${var.env}"
    })
}

# Security group rule for ingress from bastion
resource "aws_security_group_rule" "rds_ingress_bastion" {
    type                     = "ingress"
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    source_security_group_id = data.aws_security_group.bastion.id
    security_group_id        = aws_security_group.rds.id
}


# RDS instance
resource "aws_db_instance" "rds" {
    identifier                   = "${local.app}-${var.env}"
    engine                       = "postgres"
    engine_version               = "17.5"
    instance_class               = "db.t4g.micro"
    allocated_storage            = 20
    storage_type                 = "gp2"
    db_name                      = "${local.app}_${var.env}"   # Use _ not - to conform to Postgres naming rules
    username                     = "croft"
    port                         = 5432
    db_subnet_group_name         = aws_db_subnet_group.rds.name
    vpc_security_group_ids       = [aws_security_group.rds.id]
    publicly_accessible          = false
    multi_az                     = false
    storage_encrypted            = true
    deletion_protection          = false
    auto_minor_version_upgrade   = true
    backup_retention_period      = 3
    skip_final_snapshot          = true
    apply_immediately            = true                      # Add to avoid delays during password updates etc.
    copy_tags_to_snapshot        = true                      # Ensures tag inheritance
    iam_database_authentication_enabled = true               # Enable IAM database authentication
    manage_master_user_password = true

    # Recommended additional performance tweaks for small instances:
    monitoring_interval          = 0                          # Disable enhanced monitoring (can enable if needed)
    performance_insights_enabled = false                      # Also saves cost

    tags = merge(local.tags, {
        Name = "${local.app}-${var.env}"
    })
}

# Route53 record for internal database access
data "aws_ssm_parameter" "private_hosted_zone_id" {
    name = "/coreinfra/shared/private_hosted_zone_id"
}

data "aws_route53_zone" "private" {
    zone_id = data.aws_ssm_parameter.private_hosted_zone_id.value
}

resource "aws_route53_record" "croft_db" {
    zone_id = data.aws_route53_zone.private.zone_id
    name    = "${local.app}.${data.aws_route53_zone.private.name}"
    type    = "CNAME"
    ttl     = 300
    records = [aws_db_instance.rds.address]
}


