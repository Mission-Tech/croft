data "aws_vpc" "main" {
    filter {
        name   = "tag:Name"
        values = [local.conventional_coreinfra_vpc_name]
    }
}

# Data source for private subnets
data "aws_subnets" "private" {
    filter {
        name   = "tag:Name"
        values = local.conventional_coreinfra_subnets
    }
}

# Data source for bastion security group
data "aws_security_group" "bastion" {
    filter {
        name   = "tag:Name"
        values = [local.conventional_bastion_security_group_name]
    }
}
