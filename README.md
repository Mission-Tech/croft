# Croft

A Terraform-based shared database infrastructure for multi-tenant applications.

## About

Croft provides a cost-effective PostgreSQL database infrastructure that allows multiple applications to share a single RDS instance while maintaining proper isolation. Each application gets its own database with a dedicated user, stored credentials, and proper security boundaries.

## Architecture

### Core Components

- **Shared RDS Instance**: A single PostgreSQL instance that hosts multiple application databases
- **Per-App Databases**: Each application gets its own dedicated database (not just schema)
- **Isolated Users**: Each application has its own PostgreSQL user with access only to its database
- **Secure Credentials**: Database credentials are stored in AWS Systems Manager Parameter Store
- **Network Security**: RDS access is restricted to bastion hosts via security groups

### Module Structure

```
modules/
├── croft_base/             # Creates the shared RDS instance
├── croft_app_privileged/   # Creates per-app database and user (requires admin access)
├── croft_app/              # Creates security group rule for app access
├── croft_base_privileged/  # IAM permissions for applying croft_base
└── internal/privileged/    # GitHub Actions OIDC integration
```

### Security Model

- **Network Isolation**: RDS instance is in private subnets, accessible only via bastion hosts
- **Database Isolation**: Each app gets its own PostgreSQL database (not shared schemas)
- **Credential Management**: Random passwords stored in AWS SSM Parameter Store
- **Least Privilege**: Database users can only access their own database

## Usage

### 1. Deploy Base Infrastructure

First, deploy the shared RDS instance:

```hcl
# environments/dev/infra/main.tf
module "croft_base" {
    source = "../../../modules/croft_base"
    app    = "croft"
    env    = "dev"
    org    = "yourorg"
}
```

### 2. Create App Database

For each application, create a dedicated database:

```hcl
# Create app database tenant (requires privileged access)
module "database_tenant" {
    source = "path/to/croft/modules/croft_app_privileged"
    app    = "myapp"
    env    = "dev"
    org    = "yourorg"
    
    # Optional: Override connection details for terraform
    db_host = "localhost"  # For bastion proxy
    db_port = 5432
}

# Allow app to connect to database
module "database_access" {
    source = "path/to/croft/modules/croft_app"
    app    = "myapp"
    env    = "dev"
    org    = "yourorg"
    
    # Security group for your app (ECS service, Lambda, etc.)
    app_security_group_id = aws_security_group.myapp.id
}
```

### 3. Access Database Credentials

Applications can retrieve their database credentials from SSM:

```bash
# Get database credentials
aws ssm get-parameter \
    --name "/apps/myapp-dev/croft_db_credentials" \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text
```

The credential format is:
```json
{
    "username": "myapp_dev",
    "password": "generated-password",
    "host": "rds-endpoint.amazonaws.com",
    "port": 5432,
    "dbname": "myapp_dev"
}
```

### 4. Connect to Database

Applications connect directly to their database:

```bash
# Connect to your app's database
psql -h <rds-endpoint> -p 5432 -U myapp_dev -d myapp_dev
```

## Configuration

### Required Variables

All modules require these core variables:

- `app`: Application name
- `env`: Environment (dev, prod, etc.)
- `org`: Organization name

### Optional Variables

#### croft_app module

- `db_host`: Override database host (useful for terraform provider connection via proxy)
- `db_port`: Override database port
- `github_org`: GitHub organization for OIDC (when using internal/privileged module)

### Environment Setup

1. **Backend Configuration**: Update S3 bucket and DynamoDB table names in `environments/*/main.tf`
2. **Organization**: Set your organization name in the locals
3. **GitHub Integration**: Configure `github_org` for CI/CD access

## Cost Optimization

Croft is designed for cost efficiency:

- **Single RDS Instance**: Multiple apps share one `db.t4g.micro` instance
- **Minimal Storage**: 20GB GP2 storage with 1-day backup retention
- **No Multi-AZ**: Single AZ deployment for development
- **Disabled Monitoring**: Enhanced monitoring and Performance Insights disabled

## Security Best Practices

1. **Network Access**: Always connect through bastion hosts
2. **Credential Rotation**: Regularly rotate database passwords
3. **Least Privilege**: Each app can only access its own database
4. **Encryption**: All connections use SSL/TLS
5. **Backup**: Daily automated backups with 1-day retention

## Development

### Local Development

1. Set up SSH tunnel through bastion:
```bash
ssh -L 5432:rds-endpoint:5432 bastion-host
```

2. Run terraform with local connection:
```bash
terraform apply -var="db_host=localhost" -var="db_port=5432"
```

### Adding New Applications

1. Include the `croft_app` module in your app's terraform
2. Deploy with terraform apply
3. Retrieve credentials from SSM Parameter Store
4. Connect using the provided credentials

## Troubleshooting

### Connection Issues

- Ensure you're connecting through the bastion host
- Check security group rules allow bastion access
- Verify database and user were created successfully

### Permission Issues

- Confirm the database user has proper permissions
- Check that the database exists and is owned by the user
- Verify credentials in SSM Parameter Store are current

### Terraform Issues

- Ensure PostgreSQL provider can connect (may need `db_host` override)
- Check that admin credentials are available in SSM
- Verify all required variables are set
