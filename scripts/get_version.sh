#!/bin/bash

if [ $PROGRAMMING_LANGUAGE == "php" ]; then
  file="$TARGET_REPOSITORY_FOLDER/$VERSION_FILE_PATH"
  version=grep -o '\const RM_VERSION = "[^"]*"' $file
  echo "version=$version" >> $GITHUB_OUTPUT
fi

if [ $PROGRAMMING_LANGUAGE == "typescript" ]; then
  file="$TARGET_REPOSITORY_FOLDER/package.json"
  version=npm version --json | jq -r '.package'
  echo "version=" >> $GITHUB_OUTPUT
fi