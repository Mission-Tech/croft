# Croft

A Terraform-based shared database infrastructure for multi-tenant applications.

## About

Croft provides a cost-effective PostgreSQL database infrastructure that allows multiple applications to share a single RDS instance while maintaining proper isolation. Each application gets its own database with a dedicated user and the ability to create ephemeral connection tokens via IAM.

## Architecture

### Module Structure

```
modules/
├── croft_base/             # Creates the shared RDS instance. Consumed here in tf/app for Mission Tech.
├── croft_app/              # Creates the per-application resources. Consumed by applications.
```

### Security Model

- **Network Isolation**: RDS instance is in private subnets
- **Database Isolation**: Each app gets its own PostgreSQL database (not shared schemas)
- **IAM authentication**: Database credentials can be obtained by apps via [IAM database authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html)
- **Least Privilege**: Applications can only access their own databases

## Usage

### 0: Instantiate Coreinfra

This module relies on core infrastructure shared by multiple applications in each environment. Examples:
- A VPC
- A private hosted zone

At Mission Tech, this is defined in [CoreInfra](https://github.com/Mission-Tech/coreinfra). Croft assumes that
some of these resources are present.

### 1. Deploy Base Infrastructure

First, deploy the shared RDS instance into each environment:

```hcl
# environments/dev/infra/main.tf
module "croft_base" {
    source = "../../../modules/croft_base"
    app    = "croft"
    env    = "dev"
    org    = "yourorg"
}
```

See `./tf/app` as a working example.

### 2. Create App Database

Once the croft shared infrastructure is in place, each application can instantiate the `croft-app` module
to obtain a database:

```hcl
module "croft_database" {
  source = "github.com/Mission-Tech/croft//tf/modules/croft_app?ref=croft_app/v0.0.1"

  app    = local.app
  env = var.env
  org = var.org
  repo = local.repo
  tags = local.tags

  app_security_group_id = module.hoist_lambda.app_security_group_id

  db_host = var.croft_db_host
  db_port = var.croft_db_port
  app_iam_role_name = module.hoist_lambda.app_iam_role_name
}

```

For a working example, see https://github.com/Mission-Tech/puree/tree/main/tf/app

### 3. Access Database Credentials

Applications can retrieve their database credentials from SSM at runtime using [IAM authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Connecting.html)

### 4. Obtain network access

The database is created in AWS private subnets with a hostname of `croft.<org>-<env>.internal`. 

To connect locally, you can use [bastion](https://github.com/Mission-Tech/coreinfra). Example:

```shell
AWS_PROFILE=missiontech-dev bastion up croft.missiontech-dev.internal 5432 5432 --env dev --org missiontech
```

### 5: Connect as the root user

To test your database with a local connection running locally, presuming you have a local bastion proxy running, 
the AWS CLI installed, and an AWS_PROFILE with a role that can access the DB, you can run something like:

```bash
# Connect to your app's database
PGPASSWORD=$(AWS_PROFILE=missiontech-dev ./tf/modules/croft_app/generate_auth_token.sh <<<'{"hostname":"croft-dev.<rds-id>.us-east-1.rds.amazonaws.com","port":"5432","username":"croft","region":"us-east-1"}' | jq -r .token) psql "host=127.0.0.1 port=5432 user=croft dbname=croft_dev sslmode=require"
```

Where <rds-id> is replaced with the ID that appears in your actual RDS endpoint.

This pattern can also be used to connect as application users after running the croft-app module by using 
`user=<app> dbname=<app>_<env>` in the connection string.