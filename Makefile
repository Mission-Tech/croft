
.PHONY: dev-db-bastion
dev-db-bastion:
	AWS_PROFILE=${ORG}-dev bastion up croft.${ORG}-dev.internal 5432 5432 --env dev --org ${ORG}


.PHONY: prod-db-bastion
prod-db-bastion:
	AWS_PROFILE=${ORG}-prod bastion up croft.${ORG}-prod.internal 5432 5432 --env prod --org ${ORG}


.PHONY: dev-db-connect
dev-db-connect:
	PGPASSWORD=$$(aws --profile=${ORG}-dev rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-dev rds describe-db-instances \
	    --db-instance-identifier croft-dev \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft dbname=croft_dev sslmode=require"

.PHONY: prod-db-connect
prod-db-connect:
	PGPASSWORD=$$(aws --profile=${ORG}-prod rds generate-db-auth-token \
	  --hostname "$$(aws --profile=${ORG}-prod rds describe-db-instances \
	    --db-instance-identifier croft-prod \
	    --query 'DBInstances[0].Endpoint.Address' \
	    --output text)" \
	  --port 5432 --username "croft" --region us-east-1) \
	psql "host=127.0.0.1 port=5432 user=croft dbname=croft_prod sslmode=require"