terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
        postgresql = {
            source  = "cyrilgdn/postgresql"
            version = "~> 1.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "~> 3.0"
        }
    }
}

provider "postgresql" {
    host      = local.db_host
    port      = local.db_port
    database  = local.admin_db_name
    username  = local.admin_username
    password  = data.external.db_auth_token.result.token
    sslmode   = "require"
    superuser = false
}