#!/bin/bash

if [[ -z "$GIT_TAG" ]]; then
    echo "No tag provided"
    exit 1;
fi

# Add .php extension to the filename
file= "$VERSION_FILE_PATH"

# Write content to the file
echo "<?php" > "$file"
echo "" >> "$file"
echo "namespace Rentman;" >> "$file"
echo "" >> "$file"
echo "const RM_VERSION = '$GIT_TAG';"  >> "$file"

# Make sure the file is updated and display success message
if grep -q "$GIT_TAG" "$file"; then
    echo "Version file '$GIT_TAG' updated successfully!"
else
    echo "Failed to create the PHP file."
    exit 1;
fi
