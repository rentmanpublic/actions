#!/bin/bash

if [ $PROGRAMMING_LANGUAGE == "php" ]; then
  file="$TARGET_REPOSITORY_FOLDER/$VERSION_FILE_PATH"
  version=$(grep -o "const RM_VERSION = '[^']*'" $file | sed "s/const RM_VERSION = '\([^']*\)'/\1/")
  echo "determine-version=$version" >> $GITHUB_OUTPUT
fi

if [ $PROGRAMMING_LANGUAGE == "typescript" ]; then
  file="$TARGET_REPOSITORY_FOLDER/package.json"
  version=npm version --json | jq -r '.package'
  echo "determine-version=$version" >> $GITHUB_OUTPUT
fi
