#!/bin/bash
# Bootstrap script to grant rds_iam role to master user
#
# This script runs ONCE after RDS instance creation. It:
# 1. Connects using the master password (from terraform state only)
# 2. Grants the rds_iam role to the master user
# 3. After this grant, password authentication is PERMANENTLY DISABLED
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
echo "Granting rds_iam role to $USERNAME..."

# Connect and grant rds_iam role
if ! PGPASSWORD="$PASSWORD" psql \
    "host=$HOST port=$PORT dbname=$DBNAME user=$USERNAME sslmode=require" \
    -c "GRANT rds_iam TO $USERNAME;" \
    2>&1; then

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
echo "SUCCESS: rds_iam role granted to $USERNAME"
echo "=================================================="
echo "Password authentication is now DISABLED for this user."
echo "All future connections must use IAM authentication."
echo "=================================================="
