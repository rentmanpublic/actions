#!/usr/bin/env bash

if [[ -z "$SERVICE_NAME" && -z "$SERVICE_TAG" ]]; then
    echo "No service name or service tag provided. At least one of the two should be given"
    exit 1;
fi

if [[ -z "$SERVICE_TAG" && "$SERVICE_NAME" ]]; then
    # just return the name of the service
    echo "No service name provided"
    echo "service_name=$SERVICE_NAME"
    echo "service_name=$SERVICE_NAME" >> "$GITHUB_ENV"
    exit 1;
else
  SERVICE_NAME_FOUND=$(aws resourcegroupstaggingapi get-resources \
    --region "$REGION" \
    --resource-type-filters ecs:service \
    --tag-filters Key=Service,Values="$TAG_NAME" \
    --query "ResourceTagMappingList[*].ResourceARN" \
    --output text | grep "/$CLUSTER_NAME/" | awk -F'/' '{print $NF}')

    # Handle case when no output is returned
    if [[ -z "$SERVICE_NAME_FOUND" ]]; then
        echo "No service found with the tag: $SERVICE_TAG"
        exit 1
    fi
    echo "service_name=$SERVICE_NAME_FOUND"
    echo "service_name=$SERVICE_NAME_FOUND" >> "$GITHUB_ENV"
fi
