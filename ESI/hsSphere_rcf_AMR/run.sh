#!/bin/bash
cd "$(dirname "$0")"
SLURM_NTASKS=8
nMeshRefIter=3

rm -rf ./0
cp -rf 0.orig 0

blockMesh
system/updateParDict.sh -p $SLURM_NTASKS

echo "MESH_START_TIME: $(date)"

mpirun -np $SLURM_NTASKS redistributePar -decompose -parallel
mpirun -np $SLURM_NTASKS snappyHexMesh -parallel -overwrite
mpirun -np $SLURM_NTASKS redistributePar -reconstruct -constant -parallel


rm -rf processor*
rm -r *e-??

echo "DECOMPOSE_START_TIME: $(date)"

mpirun -np $SLURM_NTASKS redistributePar -decompose -parallel
echo "SOLVE_START_TIME: $(date)"

mpirun -np $SLURM_NTASKS rhoPimpleFoam -parallel
echo "RECONSTRUCT_START_TIME: $(date)"

mpirun -np $SLURM_NTASKS redistributePar -reconstruct -constant -parallel
echo "RECONSTRUCT_END_TIME: $(date)"