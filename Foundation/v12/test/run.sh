#!/bin/bash
cd "$(dirname "$0")"
nProcs=8

./Allclean.sh
cp -rf 0.org 0

blockMesh

snappyHexMesh -overwrite 

decomposePar | tee log.decomposePar
# renumberMesh -overwrite | tee log.renumberMesh

mpirun -np 8 redistributePar -parallel

# mpirun -np $nProcs foamRun -parallel | tee log.foamRun
#reconstructPar
