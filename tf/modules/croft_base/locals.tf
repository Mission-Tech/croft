# Inputs that are created by other terraform modules that we're using 
# because the names are conventional.

locals {
    app = "croft"
    # Created by coreinfra (github.com/mission-tech/coreinfra
    conventional_coreinfra_vpc_name = "${var.org}-${var.env}"

    conventional_bastion_security_group_name = "bastion-${var.env}"
}
