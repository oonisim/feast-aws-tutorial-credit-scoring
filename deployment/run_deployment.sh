#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Deploy the AWS infrastructure to run the credit scoring tutorial.
#--------------------------------------------------------------------------------
DEPLOYMENT_HOME="$(realpath "$(dirname "${0}")")"
cd "${DEPLOYMENT_HOME}" || exit

#--------------------------------------------------------------------------------
# Deploy AWS Resources with Terraform
#--------------------------------------------------------------------------------
TF_HOME="${DEPLOYMENT_HOME/aws/tf}"
chmod u+x "${TF_HOME}/run_terraform.sh"
"${TF_HOME}/run_terraform.sh"


