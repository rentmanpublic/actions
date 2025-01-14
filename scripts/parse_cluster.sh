if [[ -z "$CLUSTER_NAME" ]]; then
    echo "No environment provided"
    exit 1;
fi

# Map tag values to cluster names
case "$CLUSTER_NAME" in
    "Production")
        TAG_NAME="MainCluster"
        ;;
    "Staging")
        TAG_NAME="Staging"
        ;;
    "Util")
        TAG_NAME="Util"
        ;;
    *)
        echo "No tag defined for tag value: $CLUSTER_NAME"
        exit 1
        ;;
esac

OUTPUT=$(aws resourcegroupstaggingapi get-resources \
  --region $REGION \
  --resource-type-filters ecs:cluster \
  --tag-filters Key=ClusterName,Values=$TAG_NAME \
  --query "ResourceTagMappingList[*].ResourceARN" \
  --output text | awk -F'/' '{print $2}')

# Handle case when no output is returned
if [[ -z "$OUTPUT" ]]; then
    echo "No clusters found with the tag: ClusterName=$TAG_NAME"
    exit 1
fi
echo "cluster_name=$TAG_NAME"
echo "cluster_name=$TAG_NAME" >> $GITHUB_ENV