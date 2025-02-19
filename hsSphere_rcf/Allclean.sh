#!/bin/bash
cd "$(dirname "$0")" # Change directory to host directory for runtime of script

# List of directories to keep
KEEP_DIRS=("0.orig" "constant" "system") 

# Loop through all directories
for dir in */; do
    # Remove trailing slash
    dir=${dir%/}
    
    # Check if directory is NOT in the keep list
    if [[ ! " ${KEEP_DIRS[@]} " =~ " $dir " ]]; then
        echo "Removing $dir"
        rm -rf "$dir"
    fi
done

# delete constant/polyMesh
rm -rf "constant/polyMesh"
