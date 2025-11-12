data "aws_vpc" "main" {
    filter {
        name   = "tag:Name"
        values = [local.conventional_coreinfra_vpc_name]
    }
}

# Read VPC resources from coreinfra shared parameters
data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/coreinfra/shared/private_subnet_ids"
}

locals {
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
}

# Data source for bastion security group
data "aws_security_group" "bastion" {
    filter {
        name   = "tag:Name"
        values = [local.conventional_bastion_security_group_name]
    }
}
