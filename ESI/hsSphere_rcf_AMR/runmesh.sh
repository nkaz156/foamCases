#!/bin/bash
cd "$(dirname "$0")" # Change directory to host directory for runtime of script

while getopts p:s OPTION # colon (:) requires an input with -p
do
    case ${OPTION} in
    p)
        numProc="${OPTARG}"
        PAR='true'
        echo "Running with ${numProc} processor cores"
        ;;
    s)
        SLURM='true'
        ;;
    ?)
        echo "Invalid input argument" >&2
        usage
        exit 1
        ;;
    esac
done

./system/updateParDict.sh -p $numProc

blockMesh

decomposePar
if [[ "${SLURM}" = 'true' ]] 
then
    mpirun snappyHexMesh -parallel
else
    mpirun -np $numProc snappyHexMesh -parallel
fi

reconstructParMesh

./mvPMesh.sh


# remove processor directories

./Allclean.sh -z -p
