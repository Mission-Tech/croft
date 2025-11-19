#!/bin/bash
# Bootstrap script to set up IAM authentication for PostgreSQL
#
# This script runs ONCE after RDS instance creation. It:
# 1. Connects using the admin password (from terraform state only)
# 2. Grants the rds_iam role to the admin user
# 3. Creates croft_plan and croft_apply roles with appropriate privileges
# 4. After this grant, password authentication is PERMANENTLY DISABLED
#
# From that point forward, only IAM authentication tokens work.
# The password becomes useless and is never stored in SSM/Secrets Manager.
#
# Prerequisites:
#   - psql must be installed and in PATH
#   - Network access to the database (direct or via bastion/tunnel)
#
# Usage: grant_rds_iam_bootstrap.sh <host> <port> <dbname> <username> <password>

set -e

HOST="$1"
PORT="$2"
DBNAME="$3"
USERNAME="$4"
PASSWORD="$5"

echo "=================================================="
echo "RDS IAM Authentication Bootstrap"
echo "=================================================="
echo "Creating IAM-authenticated PostgreSQL roles..."

# Connect and execute bootstrap SQL
if PGPASSWORD="$PASSWORD" psql \
    "host=$HOST port=$PORT dbname=$DBNAME user=$USERNAME sslmode=require" \
    <<EOF
-- Grant rds_iam to admin user to enable IAM auth
GRANT rds_iam TO $USERNAME;

-- Create plan role (read-only access to system catalogs)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'croft_plan') THEN
    CREATE ROLE croft_plan LOGIN NOCREATEDB NOCREATEROLE;
  END IF;
END
\$\$;
GRANT rds_iam TO croft_plan;
GRANT CONNECT ON DATABASE $DBNAME TO croft_plan;
-- NO CREATEDB, NO CREATEROLE - can only read system catalogs

-- Create apply role (full privileges for creating app databases/roles)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'croft_apply') THEN
    CREATE ROLE croft_apply LOGIN;
  END IF;
END
\$\$;
GRANT rds_iam TO croft_apply;
GRANT CONNECT ON DATABASE $DBNAME TO croft_apply;
-- Set role attributes (CREATEDB, CREATEROLE are attributes, not grants)
ALTER ROLE croft_apply CREATEDB CREATEROLE;
-- Note: To grant rds_iam to app roles, croft_apply needs ADMIN OPTION on rds_iam
GRANT rds_iam TO croft_apply WITH ADMIN OPTION;
EOF
then
    : # Success - continue
else

    echo ""
    echo "=================================================="
    echo "ERROR: Failed to grant rds_iam role!"
    echo "=================================================="
    echo ""
    echo "This bootstrap step is critical. To fix:"
    echo ""
    echo "Option 1 - Manual Grant (if DB exists):"
    echo "  Connect to the database and run:"
    echo "    GRANT rds_iam TO $USERNAME;"
    echo ""
    echo "Option 2 - Destroy and Recreate:"
    echo "  1. Destroy the RDS instance:"
    echo "     terraform destroy -target=aws_db_instance.rds"
    echo "  2. Fix the underlying issue (network, psql, etc.)"
    echo "  3. Re-run terraform apply"
    echo ""
    echo "Common issues:"
    echo "  - psql not installed (install postgresql client)"
    echo "  - Network connectivity (check bastion/tunnel)"
    echo "  - Wrong host/port (verify db_proxy_host/db_proxy_port)"
    echo ""
    echo "See: croft/tf/modules/croft_base/README.md for details"
    echo "=================================================="
    exit 1
fi

echo ""
echo "=================================================="
echo "SUCCESS: IAM authentication bootstrap complete"
echo "=================================================="
echo "Created PostgreSQL roles:"
echo "  - $USERNAME: Primary admin user with rds_iam (password auth now DISABLED)"
echo "  - croft_plan: Read-only role for terraform plan"
echo "  - croft_apply: Full privileges for terraform apply"
echo ""
echo "All roles use IAM authentication only."
echo "=================================================="
