#!/bin/bash
cd "$(dirname "$0")" # Change directory to host directory for runtime of script

# Find latest mesh directory
highest_dir=0
highest_num=-INF  # Start with a very low value

# Loop through all directories in the current location
for dir in */; do
    dir=${dir%/}  # Remove trailing slash
    # echo "$dir"

    # Check if directory name is a valid number
    if [[ $dir =~ ^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$ ]]; then
        highest_dir=$(awk -v c="$dir" -v h="$highest_dir" 'BEGIN {if (c < h) print h; else print c}')
    fi
done

# Output the highest numbered directory
if [[ -n $highest_dir ]]; then
    echo "Highest numbered directory: $highest_dir. Moving to constant/polyMesh"
else
    echo "No valid numbered directories found."
fi

rm -rf constant/polyMesh

mv "$highest_dir/polyMesh" constant