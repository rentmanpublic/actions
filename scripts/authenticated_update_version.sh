#!/bin/bash


if [[ -z "$GIT_TAG" ]]; then
    echo "No tag provided"
    exit 1;
fi

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
    git remote set-url origin https://$GITHUB_TOKEN@github.com/BuildBot/$TARGET_REPOSITORY.git
    git add $VERSION_FILE_PATH
    git commit -m "Bump version to $GIT_TAG"
    git tag $GIT_TAG
    git push
    git push origin tag $GIT_TAG

    echo "Version file '$GIT_TAG' updated successfully!"
else
    echo "Failed to create the PHP file."
    exit 1;
fi
