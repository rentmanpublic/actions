#!/usr/bin/env bash

# Expects the following environment variables to be set before execution:
# - ENVIRONMENT

set -euxo pipefail

if [[ -z "$ENVIRONMENT" ]]; then
    echo "No environment provided"
    exit 1;
fi

# Check if there is a deployment config in the project repository
deployment_file_path="target_repository_folder/deployment/workflows/config.json"

if [[ ! -f $deployment_file_path ]]; then
  echo "No deployment config json file in deployment/workflow folder of project repository."
  exit 1
fi

# Get all AWS ecs deployment information from the deployment config based on environment
service_tag=$(jq -r ".ecsServiceTag" $deployment_file_path)

# We use the || to keep this backwards compatible, when the left hand statement fails with an error
# and exit code 1, it'll try the original statement so we keep this backwards compatible.
# We redirect the stderr output of the left hand side to /dev/null so we don't see the error logged, which might
# confuse people even if it doesn't actually impact execution.
service_names_found=$(jq -r ".environments.$ENVIRONMENT.ecsServiceName[]" $deployment_file_path 2> /dev/null || jq -r ".environments.$ENVIRONMENT.ecsServiceName" $deployment_file_path)
cluster_name=$(jq -r ".environments.$ENVIRONMENT.ecsCluster" $deployment_file_path)
regions=$(jq -r ".environments.$ENVIRONMENT.ecsRegions[]" $deployment_file_path)

lowercase_cluster_name=$(echo "$cluster_name" | tr '[:upper:]' '[:lower:]')

# Determine if the config is valid
if [[ -z $cluster_name || -z $regions ]]; then
  echo "There is no cluster or region configured for the environment $ENVIRONMENT"
  exit 1
fi

# Map tag values to cluster names in AWS
case "$lowercase_cluster_name" in
    "rm4g")
        cluster_tag="MainCluster"
        ;;
    "staging")
        cluster_tag="Staging"
        ;;
    "util")
        cluster_tag="Util"
        ;;
    *)
        echo "No tag defined for tag value: $lowercase_cluster_name"
        exit 1
        ;;
esac

## Loop through the regions in an environment that need to be deployed to
for region_name in ${regions}; do
  # Set AWS config region
  export AWS_DEFAULT_REGION=$region_name

  # get cluster name
  cluster_name_from_aws=$(aws resourcegroupstaggingapi get-resources \
    --region "$region_name" \
    --resource-type-filters ecs:cluster \
    --tag-filters Key=ClusterName,Values="$cluster_tag" \
    --query "ResourceTagMappingList[*].ResourceARN" \
    --output text | awk -F'/' '{print $2}')

  # Handle case when no output is returned
  if [[ -z "$cluster_name_from_aws" ]]; then
      echo "No clusters found with the tag: ClusterName=$cluster_tag"
      exit 1
  fi

  # get service name by tag if needed, else use service name
  if [[ -z "$service_names_found" && -z "$service_tag" ]]; then
      echo "No service name or service tag provided. At least one of the two should be given"
      exit 1
  fi

  if [[ "$service_tag" != "null" ]]; then
    service_names_found=()
    echo "Getting Service name for service tag: $service_tag"
    service_names=$(aws resourcegroupstaggingapi get-resources \
      --region "$region_name" \
      --resource-type-filters ecs:service \
      --tag-filters Key=Service,Values="$service_tag" \
      --query "ResourceTagMappingList[*].ResourceARN" \
      --output json)

    if [[ -z "$service_names" ]]; then
        echo "No service found with the tag: $service_tag"
        exit 1
    fi

    for service in ${service_names}; do
        # we do some sort of glob matching in this if statement, this relies on the long ARN format
        if [[ "$service" == *"service/$cluster_name_from_aws"* ]]; then
            service_names_found+=("$(echo "$service" | awk -F'/' '{print $NF}' | sed 's/[",]//g')")
        fi
    done

    # Handle case when no output is returned
    if [[ -z "${service_names_found[*]}" ]]; then
        echo "No service found with the tag: $service_tag"
        exit 1
    fi

    echo "Found service with name $service_names_found"
  fi

  for service in ${service_names_found}; do
    # redeploy service
    echo "Redeploying service $service in cluster $cluster_name_from_aws in region $region_name"
    aws ecs update-service --cluster "$cluster_name_from_aws" --service "$service" --region "$region_name" --force-new-deployment
  done
done