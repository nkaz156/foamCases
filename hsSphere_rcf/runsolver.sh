#!/bin/bash

# cp -r "0.orig" "0"

decomposePar

mpirun -np 10 rhoCentralFoam -parallel

reconstructPar

rm -r processor*/