#!/bin/bash


if [[ -z "$GIT_TAG" ]]; then
    echo "No tag provided"
    exit 1;
fi

if [ $PROGRAMMING_LANGUAGE == "php" ]; then
  # Add .php extension to the filename
  file="$TARGET_REPOSITORY_FOLDER/$VERSION_FILE_PATH"

  echo 'Starting'
  if [ -f $file ]; then
    chmod 700 $file
  else
    echo "File does not exist:"
    ls -l
  fi

  # Write content to the file
  echo "<?php" > "$file"
  echo "" >> "$file"
  echo "namespace Rentman;" >> "$file"
  echo "" >> "$file"
  echo "const RM_VERSION = '$GIT_TAG';"  >> "$file"
  # Make sure the file is updated and display success message
  if grep -q "$GIT_TAG" "$file"; then

    cd ./$TARGET_REPOSITORY_FOLDER

    git config user.name BuildBot
    git config user.email buildbot@rentman.nl

    git add $VERSION_FILE_PATH
    git commit -m "Bump version to $GIT_TAG"
    git tag $GIT_TAG


    if ! git push; then
      echo "Failed to push the version file"
      exit 1
    fi

    if !git push origin tag $GIT_TAG; then
      echo "Failed to push tag $GIT_TAG"
      exit 1
    fi

      echo "Version file '$GIT_TAG' updated successfully!"
  else
      echo "Failed to create the version file."
      exit 1;
  fi
fi

if [ $PROGRAMMING_LANGUAGE == "typescript" ]; then
  # Write content to the file
  cd ./$TARGET_REPOSITORY_FOLDER
  npm version minor
  git push
fi
