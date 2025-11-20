#!/bin/bash
# Generate RDS IAM auth token for PostgreSQL provider
# Inputs (via stdin as JSON): hostname, port, username, region

# Example invocation:
# AWS_PROFILE=missiontech-dev ./generate_auth_token.sh <<<'{"hostname":"croft-dev.<id>.us-east-1.rds.amazonaws.com","port":"5432","username":"croft","region":"us-east-1"}'
#
# Note that the HOSTNAME must be the _actual RDS hostname_, not a proxy or cname.

set -e

# Parse input
eval "$(jq -r '@sh "HOSTNAME=\(.hostname) PORT=\(.port) USERNAME=\(.username) REGION=\(.region)"')"

# Generate auth token
TOKEN=$(aws rds generate-db-auth-token \
    --hostname "$HOSTNAME" \
    --port "$PORT" \
    --username "$USERNAME" \
    --region "$REGION")

# Output as JSON
jq -n --arg token "$TOKEN" '{"token":$token}' | tee /tmp/log2
