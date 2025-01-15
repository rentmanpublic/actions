#!/bin/bash

if [ "$SELECTED_ECS_CLUSTER" == "RM4G" ]; then
  if [ -n "$PRODUCTION_IMAGE_NAME" ]; then
    echo "image_name=$PRODUCTION_IMAGE_NAME" >> $GITHUB_OUTPUT
    exit 0
  fi

elif [ "$SELECTED_ECS_CLUSTER" == "Staging" ]; then
  if [ -n "$STAGING_IMAGE_NAME" ]; then
    echo "image_name=$STAGING_IMAGE_NAME" >> $GITHUB_OUTPUT
    exit 0
  fi

elif [ "$SELECTED_ECS_CLUSTER" == "Util" ]; then
  if [ -n "$UTIL_IMAGE_NAME" ]; then
    echo "image_name=$UTIL_IMAGE_NAME" >> $GITHUB_OUTPUT
    exit 0
  fi
fi

echo "Invalid image name config for environment $SELECTED_ECS_CLUSTER"
exit 1
