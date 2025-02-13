#!/bin/bash
# Expects the following environment variables to be set before execution:
# - $ENVIRONMENT

set -euxo pipefail

if [[ -z "$ENVIRONMENT" ]]; then
    echo "No environment provided"
    exit 1;
fi

deployment_file_path="target_repository_folder/deployment/workflows/config.json"

if [[ ! -f $deployment_file_path ]]; then
  echo "No deployment config json file in deployment/workflow folder of project repository."
  exit 1
fi

service_name=$(jq -r ".environments.$ENVIRONMENT.ecrImageName" $deployment_file_path)

if [[ -z "$service_name" ]]; then
    echo "No ECR image name provided for environment $ENVIRONMENT in the config file: deployment/workflows/config.json"
    exit 1;
fi

echo "image_name=$service_name" >> "$GITHUB_OUTPUT"
