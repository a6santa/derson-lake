init:
	terraform init -reconfigure \
		-backend-config="access_key=MY_ACCESS_KEY" \
        -backend-config="secret_key=MY_SECRET_KEY" \
        -backend-config="region=MY_REGION" \
		-backend-config="bucket=my_bucket" \
		-backend-config="dynamodb_table=my_dynamodb_table" \
		-upgrade