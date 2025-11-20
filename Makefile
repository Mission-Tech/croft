

############################################
########### Root Database Access ###########
############################################

# Dependencies:
# - aws command line
# - [bastion](https://github.com/mission-tech/bastion)
# - psql
# - `ORG` env var set to your organization name

# Use [bastion](https://github.com/mission-tech/bastion) to port-forward to the dev db
.PHONY: dev-db-bastion
dev-db-bastion:
	AWS_PROFILE=${ORG}-dev bastion up croft.${ORG}-dev.internal 5432 5432 --env dev --org ${ORG}

# Use [bastion](https://github.com/mission-tech/bastion) to port-forward to the prod db
.PHONY: prod-db-bastion
prod-db-bastion:
	AWS_PROFILE=${ORG}-prod bastion up croft.${ORG}-prod.internal 5432 5432 --env prod --org ${ORG}

.PHONY: dev-db-connect-plan
dev-db-connect-plan:
	PGPASSWORD=$$(aws --profile=${ORG}-dev rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-dev rds describe-db-instances \
	    --db-instance-identifier croft-dev \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft_plan" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft_plan dbname=croft_dev sslmode=require"

.PHONY: dev-db-connect-apply
dev-db-connect-apply:
	PGPASSWORD=$$(aws --profile=${ORG}-dev rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-dev rds describe-db-instances \
	    --db-instance-identifier croft-dev \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft_apply" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft_apply dbname=croft_dev sslmode=require"

# Use psql to connect to the dev db (requires a port-forward on 5432, see dev-db-bastion)
.PHONY: dev-db-connect
dev-db-connect:
	PGPASSWORD=$$(aws --profile=${ORG}-dev rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-dev rds describe-db-instances \
	    --db-instance-identifier croft-dev \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft dbname=croft_dev sslmode=require"

.PHONY: prod-db-connect-plan
prod-db-connect-plan:
	PGPASSWORD=$$(aws --profile=${ORG}-prod rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-prod rds describe-db-instances \
	    --db-instance-identifier croft-prod \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft_plan" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft_plan dbname=croft_prod sslmode=require"

.PHONY: prod-db-connect-apply
prod-db-connect-apply:
	PGPASSWORD=$$(aws --profile=${ORG}-prod rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-prod rds describe-db-instances \
	    --db-instance-identifier croft-prod \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft_apply" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft_apply dbname=croft_prod sslmode=require"

# Use psql to connect to the prod db (requires a port-forward on 5432, see prod-db-bastion)
.PHONY: prod-db-connect
prod-db-connect:
	PGPASSWORD=$$(aws --profile=${ORG}-prod rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-prod rds describe-db-instances \
	    --db-instance-identifier croft-prod \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft dbname=croft_prod sslmode=require"