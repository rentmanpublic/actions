#!/usr/bin/env bash

set -euxo pipefail

version="$1"

if [[ -z "$version" ]]; then
	echo "No version provided, usage: ./prepare-release.sh 2"
	exit 1;
fi

# Update version referenced in all workflows
# In macOS sed requires an empty string after -i to work, if you are on linux please remove it in case it gives an error
sed -E -i '' "s/(rentmanpublic\/.*@v)[0-9]+(\.[0-9]+)*/\1$version/g" .github/workflows/*

git add .github/workflows/*
git commit -m "Prepare version $version"
git tag "v$version"

echo "Please double check you are happy with the release and then push the tag"
