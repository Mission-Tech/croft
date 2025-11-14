# croft_base

A terraform module that creates the croft database per-environment with IAM-only authentication.

See sample instantiations that manage Mission Tech's instantiations of this module in environments/{dev,prod}/infra

To run this module, you'll need the IAM permissions defined in ../croft_base_meta

## IAM Authentication Bootstrap

This module implements a **zero-static-credentials** approach using RDS IAM database authentication.

### How It Works

1. **RDS Instance Creation**: A PostgreSQL RDS instance is created with `iam_database_authentication_enabled = true` and a random password (required by AWS but never stored externally).

2. **One-Time Bootstrap**: After RDS creation, a `local-exec` provisioner runs the `grant_rds_iam_bootstrap.sh` script that:
   - Connects to the database using the temporary password (exists only in terraform state)
   - Executes `GRANT rds_iam TO croft;` to enable IAM authentication for the master user
   - After this grant, **password authentication is permanently disabled** for the `croft` user

3. **IAM-Only Access**: From this point forward, the database only accepts IAM authentication tokens. The password becomes useless and is never stored in SSM/Secrets Manager.

### Prerequisites

The terraform execution environment must have:

1. **PostgreSQL client (`psql`)** installed and available in PATH
   - macOS: `brew install postgresql`
   - Linux: `apt-get install postgresql-client` or `yum install postgresql`
2. **Network access** to the database:
   - **Remote execution** (CI/CD): Direct access to RDS endpoint within VPC
   - **Local execution**: Bastion/SSH tunnel to port 5432

### Configuration

#### Remote Execution (Default)

By default, the module connects directly to the RDS endpoint:

```hcl
module "croft_base" {
  source = "../modules/croft_base"
  env    = "dev"
  org    = "myorg"
  # ... other required variables
  # db_proxy_host and db_proxy_port default to RDS endpoint
}
```

#### Local Execution (via Bastion)

When running terraform locally through a bastion/SSH tunnel:

```hcl
module "croft_base" {
  source = "../modules/croft_base"
  env    = "dev"
  org    = "myorg"
  # ... other required variables

  # Override for bastion proxy
  db_proxy_host = "127.0.0.1"
  db_proxy_port = 5432  # Local port forwarded to RDS
}
```

### Security Benefits

- ✅ **No static credentials** stored in SSM, Secrets Manager, or anywhere else
- ✅ **Password authentication disabled** after bootstrap
- ✅ **Pure IAM-based access** - all authentication via short-lived tokens
- ✅ **No credential rotation** needed
- ✅ **Auditable** through CloudTrail IAM events

### Troubleshooting

**Bootstrap fails with "psql: command not found":**
- Install PostgreSQL client (see Prerequisites above)

**Bootstrap fails with "connection refused":**
- Verify bastion/SSH tunnel is running and forwarding to correct port
- Check security groups allow access from terraform execution environment

**Bootstrap fails with "permission denied":**
- Ensure the IAM role running terraform has `rds-db:connect` permission for the master user
