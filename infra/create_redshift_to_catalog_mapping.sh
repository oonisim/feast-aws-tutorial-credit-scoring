#!/usr/bin/env bash
set -e

AWS_REGION="ap-southeast-2"
REDSHIFT_CLUSTER_IDENTIFIER="$(terraform output -json | jq -r '.redshift_cluster_identifier.value')"
REDSHIFT_SPECTRUM_ARN="$(terraform output -json | jq -r '.redshift_spectrum_arn.value')"


echo "creating a mapping from the Redshift cluster to the external catalog..."
SQL_CATALOG_STATEMENT_ID=$(aws redshift-data execute-statement \
    --region "${AWS_REGION}" \
    --cluster-identifier "${REDSHIFT_CLUSTER_IDENTIFIER}" \
    --db-user admin \
    --database dev --sql "create external schema spectrum from data catalog database 'dev' iam_role \
    '${REDSHIFT_SPECTRUM_ARN}' create external database if not exists;" \
    --output text \
    --query 'Id' \
)

echo "sleeping 10 secs..."
sleep 10

echo "verifying the mapping creation statement ${SQL_CATALOG_STATEMENT_ID}..."
aws redshift-data describe-statement \
    --region "${AWS_REGION}" \
    --id "${SQL_CATALOG_STATEMENT_ID}"


echo "querying an actual zip code..."
SQL_QUERY_STATEMENT_ID=$(aws redshift-data execute-statement \
    --region "${AWS_REGION}" \
    --cluster-identifier "${REDSHIFT_CLUSTER_IDENTIFIER}" \
    --db-user admin \
    --database dev --sql "SELECT * from spectrum.zipcode_features LIMIT 1;" \
    --output text \
    --query 'Id' \
)

echo "sleeping 5 secs..."
sleep 5

echo "verifying the query statement ${SQL_QUERY_STATEMENT_ID}..."
aws redshift-data describe-statement \
    --region "${AWS_REGION}" \
    --id "${SQL_QUERY_STATEMENT_ID}"
