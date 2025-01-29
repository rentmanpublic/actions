#!/usr/bin/env bash

if [[ -z "$SERVICE_NAME" ]]; then
    echo "No environment provided"
    exit 1;
fi

SERVICE_NAME_LOWER=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]')

# Map the values of the service name in github actions to the tag names in the ECS cluster
case "$SERVICE_NAME_LOWER" in
    "tools")
        TAG_NAME="toolsendpoint"
        ;;
    "slack")
        TAG_NAME="rentman-slack"
        ;;
    "adminserver")
        TAG_NAME="adminserver"
        ;;
    "worker-scheduler")
        TAG_NAME="worker-scheduler"
        ;;
    "versiondiscovery")
        TAG_NAME="versiondiscovery"
        ;;
    "rentman-translations")
        TAG_NAME="translations"
        ;;
    *)
        echo "No tag defined for tag value: $SERVICE_NAME"
        exit 1
        ;;
esac

OUTPUT=$(aws resourcegroupstaggingapi get-resources \
  --region "$REGION" \
  --resource-type-filters ecs:service \
  --tag-filters Key=Service,Values="$TAG_NAME" \
  --query "ResourceTagMappingList[*].ResourceARN" \
  --output text | grep "/$CLUSTER_NAME/" | awk -F'/' '{print $NF}')

# Handle case when no output is returned
if [[ -z "$OUTPUT" ]]; then
    echo "No clusters found with the tag: ClusterName=$OUTPUT"
    exit 1
fi
echo "service_name=$OUTPUT"
echo "service_name=$OUTPUT" >> "$GITHUB_ENV"
