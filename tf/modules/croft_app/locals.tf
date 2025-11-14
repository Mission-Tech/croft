# Conventional names and settings based on croft_base module
locals {
    # Database connection info
    admin_db_name = "croft_${var.env}"  # Admin database for creating new databases
    app_db_name = "${var.app}_${var.env}"  # App-specific database
    db_host = coalesce(var.db_host, data.aws_db_instance.croft.address)
    db_port = coalesce(var.db_port, data.aws_db_instance.croft.port)

    # Real RDS endpoint for IAM token generation (always the actual endpoint, never proxy)
    # IAM tokens are cryptographically bound to the specific hostname
    db_endpoint = data.aws_db_instance.croft.address
    db_endpoint_port = data.aws_db_instance.croft.port

    # Admin credentials
    admin_username = "croft"

    # Per-app tenant naming
    role_name = "${var.app}_${var.env}"

    # Database DNS name for app connections (using private hosted zone)
    db_dns_name = "croft.${data.aws_route53_zone.private.name}"
}
