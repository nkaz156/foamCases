#!/bin/bash
cd "$(dirname "$0")" # Change directory to host directory for runtime of script

while getopts zp OPTION # colon (:) requires an input with -p
do
    case ${OPTION} in
    z)
        KEEPZERO='true'

        ;;
    p)
        KEEP_PM='true'

        ;;
    ?)
        echo "Invalid input argument" >&2
        usage
        exit 1
        ;;
    esac
done

# List of directories to keep

KEEP_DIRS=("0.orig" "constant" "system") 
if [[ "${KEEPZERO}" = 'true' ]]
then
    KEEP_DIRS=("0.orig" "constant" "system" "0") 
fi

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
if [[ "${KEEP_PM}" != 'true' ]]
then
    rm -rf "constant/polyMesh"
fi
