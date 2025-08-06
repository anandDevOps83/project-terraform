#!/bin/bash
if [ $# -ne 2]; then
echo "$0 env(dev|prod) action(apply|destroy)"
exit 1
fi

git pull
rm -fr .terraform
terraform init -back-config=env-${1}/state.tfvars
terraform $2 -var-file=env-${1}/main.tfvars -auto-approve