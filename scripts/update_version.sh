#!/bin/bash

git config --global user.name BuildBot
git config --global user.email buildbot@rentman.nl

if [[ -z "$GIT_TAG" ]]; then
    echo "No tag provided"
    exit 1;
fi



if [ "$PROGRAMMING_LANGUAGE" == "php" ]; then
  # Add .php extension to the filename
  file="$TARGET_REPOSITORY_FOLDER/$VERSION_FILE_PATH"

  echo 'Starting'
  if [ -f "$file" ]; then
    chmod 700 "$file"
  else
    echo "File does not exist:"
    ls -l
  fi

  echo "<?php" > "$file"

  # Write content to the file
  {
    echo ""
    echo "namespace Rentman;"
    echo ""
    echo "const RM_VERSION = '$GIT_TAG';"
  } >> "$file"
  # Make sure the file is updated and display success message
  if grep -q "$GIT_TAG" "$file"; then

    cd ./"$TARGET_REPOSITORY_FOLDER" || exit

    git add "$VERSION_FILE_PATH"

    echo "Version file '$GIT_TAG' updated successfully!"
  else
      echo "Failed to create the version file."
      exit 1;
  fi
fi

if [ "$PROGRAMMING_LANGUAGE" == "typescript" ]; then

  file="$TARGET_REPOSITORY_FOLDER/package.json"

  echo 'Starting'
  # make sure we are allowed to change the package.json file
  if [ -f "$file" ]; then
    chmod 700 "$file"
  else
    echo "File does not exist:"
  fi

  cd ./"$TARGET_REPOSITORY_FOLDER" || exit

  # Write content to the file

  # find and replace "version" in package.json
  sed -i "/version/c\\  \"version\": \"$GIT_TAG\"," package.json

  # update package log without installing node_modules
  npm i --package-lock-only
  # git add files
  git add package.json package-lock.json

  echo "Package json updated successfully!"
fi


# git commit files and tags and push both
git commit -m "Bump version to $GIT_TAG"
git tag "$GIT_TAG"

if ! git push; then
  echo "Failed to push the version file"
  exit 1
fi
if ! git push origin tag "$GIT_TAG"; then
  echo "Failed to push tag"
  exit 1
fi
