#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Deploy AWS Resources
#--------------------------------------------------------------------------------
set -e

TF_HOME="$(realpath "$(dirname "${0}")")"
cd "${TF_HOME}" || exit

TIMESTAMP="$(date +%Y%b%d%H%M%S | tr '[:lower:]' '[:upper:]')"
TF_PLAN="${TIMESTAMP}.tfplan"

echo "terraform: generating a plan..."
terraform plan \
-var="admin_password=${PASSWORD:?Set PASSWORD environment variable}" \
-var="feast_registry_db_password=${PASSWORD:?Set PASSWORD environment variable}" \
-var-file=clab.tfvars \
-out="${TF_PLAN}"

echo "showing the plan to use..."
terraform show "$PLAN_FILE"\

echo "applying the plan..."
terraform apply "${TF_PLAN}"

mkdir -p tfplans_executed
ln "${TF_PLAN}" latest.tfplan
mv "${TF_PLAN}" tfplans_executed

