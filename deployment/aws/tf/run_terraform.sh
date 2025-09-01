#!/usr/bin/env bash
set -e

terraform plan \
-var="admin_password=${PASSWORD:?Set PASSWORD environment variable}" \
-var="feast_registry_db_password=${PASSWORD:?Set PASSWORD environment variable}" \
-var-file=clab.tfvars

terraform apply \
-var="admin_password=${PASSWORD:?Set PASSWORD environment variable}" \
-var="feast_registry_db_password=${PASSWORD:?Set PASSWORD environment variable}" \
-var-file=clab.tfvars
