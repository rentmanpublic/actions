#!/usr/bin/env bash

# Expects the following environment variables to be set before execution:
# - ENVIRONMENT

set -euxo pipefail
#Set AWS credentials for this shell script run
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

if [[ -z "$ENVIRONMENT" ]]; then
    echo "No environment provided"
    exit 1;
fi

deployment_file_path="target_repository_folder/deployment/workflows/config.json"
chmod 700 $deployment_file_path

if [[ ! -f $deployment_file_path ]]; then
  echo "No deployment config json file in deployment/workflow folder of project repository."
  exit 1
fi


deployment_config=$(cat $deployment_file_path)

service_tag=$(jq -r ".ecsServiceTag" $deployment_file_path)
service_name=$(jq -r ".environments.$ENVIRONMENT.ecsImageName" $deployment_file_path)
cluster_name=$(jq -r ".environments.$ENVIRONMENT.ecsCluster" $deployment_file_path)
regions=$(jq -r ".environments.$ENVIRONMENT.ecsRegions[]" $deployment_file_path)

lowercase_cluster_name=$(echo "$cluster_name" | tr '[:upper:]' '[:lower:]')

echo "environment: $ENVIRONMENT"
echo "cluster_name: $cluster_name, $lowercase_cluster_name"
echo "service_name: $service_name"
echo "service_tag: $service_tag"
echo "regions: $regions"

# Map tag values to cluster names
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

## for loop per region
for region_name in ${regions}; do
  # Set AWS config region
  echo "Looping over region $region_name"
  export AWS_DEFAULT_REGION=$region_name

  # get cluster name
  OUTPUT=$(aws resourcegroupstaggingapi get-resources \
    --region "$region_name" \
    --resource-type-filters ecs:cluster \
    --tag-filters Key=ClusterName,Values="$cluster_tag" \
    --query "ResourceTagMappingList[*].ResourceARN" \
    --output text | awk -F'/' '{print $2}')

  # Handle case when no output is returned
  if [[ -z "$OUTPUT" ]]; then
      echo "No clusters found with the tag: ClusterName=$OUTPUT"
      exit 1
  fi

  # get service name by tag if needed, else use service name

  if [[ -z "$service_name" && -z "$service_tag" ]]; then
      echo "No service name or service tag provided. At least one of the two should be given"
      exit 1
  fi

  if [[ -n "$service_tag" ]]; then
    echo "Getting service tag $service_tag"
    service_names=$(aws resourcegroupstaggingapi get-resources \
      --region "$region_name" \
      --resource-type-filters ecs:service \
      --tag-filters Key=Service,Values="$service_tag" \
      --query "ResourceTagMappingList[*].ResourceARN" \
      --output json)

    echo "Output of request: $service_names for region: $region_name in cluster: $lowercase_cluster_name"

    if [[ -z "$service_names" ]]; then
        echo "No service found with the tag: $service_tag"
        exit 1
    fi

    for service in ${service_names}; do
        if [[ "$service" == *"service/$lowercase_cluster_name"* ]]; then
            service_name_found=$(echo "$service" | awk -F'/' '{print $NF}' | sed 's/[",]//g')
        fi
    done

    # Handle case when no output is returned
    if [[ -z "$service_name_found" ]]; then
        echo "No service found with the tag: $service_tag"
        exit 1
    fi

    echo "Found service with name $service_name_found"
  fi

  # redeploy service
  echo "Redeploying service $service_name_found in cluster $lowercase_cluster_name in region $region_name"
  aws ecs update-service --cluster $lowercase_cluster_name --service $service_name_found --region $region_name --force-new-deployment
done