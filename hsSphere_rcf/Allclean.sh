#!/usr/bin/env bash
cd "$(dirname "$0")"

echo "Deleting old files"
rm -r processor*
rm -r constant/polyMesh
for dir in */; do
    # Remove the trailing slash from the directory name
    dir=${dir%/}

    # Check if the name is a number and is not "0"
    if [[ "$dir" =~ ^[0-9]+$ ]] && [[ "$dir" -ne 0 ]]; then
        echo "Removing directory: $dir"
        rm -r "$dir"
    fi
done