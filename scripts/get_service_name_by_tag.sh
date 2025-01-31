#!/usr/bin/env bash

if [[ -z "$SERVICE_NAME" && -z "$SERVICE_TAG" ]]; then
    echo "No service name or service tag provided. At least one of the two should be given"
    exit 1
fi

if [[ -z "$SERVICE_TAG" && "$SERVICE_NAME" ]]; then
    # just return the name of the service
    echo "No service tag provided, using name"
    echo "service_name=$SERVICE_NAME"
    echo "service_name=$SERVICE_NAME" >> "$GITHUB_OUTPUT"
    exit 0
else
  echo "Getting service tag $SERVICE_TAG"
  SERVICE_NAME_FOUND=$(aws resourcegroupstaggingapi get-resources \
    --region "$REGION" \
    --resource-type-filters ecs:service \
    --tag-filters Key=Service,Values="$SERVICE_TAG" \
    --query "ResourceTagMappingList[*].ResourceARN" \
    --output text | grep "/$CLUSTER_NAME/" | awk -F'/' '{print $NF}')

echo "Output of aws request: $SERVICE_NAME_FOUND"
    # Handle case when no output is returned
    if [[ -z "$SERVICE_NAME_FOUND" ]]; then
        echo "No service found with the tag: $SERVICE_TAG"
        exit 1
    fi
    echo "service_name=$SERVICE_NAME_FOUND"
    echo "service_name=$SERVICE_NAME_FOUND" >> "$GITHUB_OUTPUT"
fi
