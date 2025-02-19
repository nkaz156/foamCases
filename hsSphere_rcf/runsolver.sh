#!/bin/bash
cd "$(dirname "$0")" # Change directory to host directory for runtime of script

cp -R 0.orig 0

decomposePar

while getopts p:s OPTION # colon (:) requires an input with -p
do
    case ${OPTION} in
    p)
        numProc="${OPTARG}"
        PAR='true'
        print "Running with ${numProc} processor cores"
        ;;
    s)
        SLURM='true'
        print "Running with mesher enabled"
        ;;
    ?)
        echo "Invalid input argument" >&2
        usage
        exit 1
        ;;
    esac
done

./system/updateParDict -p $numProc

decomposePar
if [[ "${SLURM}" = 'true' ]] 
then
    mpirun rhoCentralFoam -parallel
else
    mpirun -np $numProc rhoCentralFoam -parallel
fi

reconstructPar

rm -r processor*/