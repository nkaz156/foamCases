#!/bin/bash
cd "$(dirname "$0")" # Change directory to host directory for runtime of script

blockMesh

decomposePar

mpirun -np 8 snappyHexMesh -parallel

reconstructParMesh

# Find latest mesh directory
highest_dir=""
highest_num=-INF  # Start with a very low value

# Loop through all directories in the current location
for dir in */; do
    dir=${dir%/}  # Remove trailing slash
    # echo "$dir"

    # Check if directory name is a valid number
    if [[ $dir =~ ^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$ ]]; then
        sed -n -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$dir"
        num=$(echo "$dir" | bc -l)     # Convert to float for comparison
        #num=$dir

        # Update highest number and directory
        if (( $(echo "$num > $highest_num" | bc -l) )); then
            highest_num=$num
            highest_dir=$dir
            #echo "$dir"
        fi
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

# remove processor directories

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