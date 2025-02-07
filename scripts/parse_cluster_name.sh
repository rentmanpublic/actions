#!/usr/bin/env bash
# Expects the following environment variables to be set before execution:
# - ENVIRONMENT_NAME
# - REGION
# - TAG_NAME


set -euxo pipefail

if [[ -z "$ENVIRONMENT_NAME" ]]; then
    echo "No environment provided"
    exit 1;
fi

ENVIRONMENT_NAME_LOWER=$(echo "$ENVIRONMENT_NAME" | tr '[:upper:]' '[:lower:]')

# Map tag values to cluster names
case "$ENVIRONMENT_NAME_LOWER" in
    "rm4g")
        TAG_NAME="MainCluster"
        ;;
    "staging")
        TAG_NAME="Staging"
        ;;
    "util")
        TAG_NAME="Util"
        ;;
    *)
        echo "No tag defined for tag value: $ENVIRONMENT_NAME"
        exit 1
        ;;
esac

OUTPUT=$(aws resourcegroupstaggingapi get-resources \
  --region "$REGION" \
  --resource-type-filters ecs:cluster \
  --tag-filters Key=ClusterName,Values="$TAG_NAME" \
  --query "ResourceTagMappingList[*].ResourceARN" \
  --output text | awk -F'/' '{print $2}')

# Handle case when no output is returned
if [[ -z "$OUTPUT" ]]; then
    echo "No clusters found with the tag: ClusterName=$OUTPUT"
    exit 1
fi
echo "cluster_name=$OUTPUT"
echo "cluster_name=$OUTPUT" >> "$GITHUB_OUTPUT"
