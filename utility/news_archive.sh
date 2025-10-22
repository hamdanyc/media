#!/bin/bash

# Create archive directory if it doesn't exist
mkdir -p archive

# Read all .R files (excluding archive folder)
all_files=($(find . -maxdepth 1 -type f -name "*.R" -not -path "./archive/*" -printf "%f\n"))

# Extract active files from newsdailyBat.R
thenews_files=($(grep -o '"[^"]*"' newsdailyBat.R | tr -d '"'))
active_files=("${thenews_files[@]}" news_rs_part.R newsadddb_mongo.R)

# Move inactive files to archive
for file in "${all_files[@]}"; do
    if [[ ! " ${active_files[@]} " =~ " ${file} " && "$file" != "newsdailyBat.R" ]]; then
        mv "./$file" archive/
    fi
done

echo "Inactive .R files have been moved to the 'archive' folder."
