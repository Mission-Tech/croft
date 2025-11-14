# Inputs that are created by other terraform modules that we're using
# because the names are conventional.

locals {
    app = "croft"
    # Created by coreinfra (github.com/mission-tech/coreinfra
    conventional_coreinfra_vpc_name = "${var.org}-${var.env}"

    conventional_bastion_security_group_name = "bastion-${var.env}"

    # Database connection settings for bootstrap
    # Defaults to actual RDS endpoint, but can be overridden for local development with bastion proxy
    bootstrap_db_host = coalesce(var.db_proxy_host, aws_db_instance.rds.address)
    bootstrap_db_port = coalesce(var.db_proxy_port, aws_db_instance.rds.port)
}
