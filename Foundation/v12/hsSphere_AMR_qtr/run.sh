#!/bin/bash
cd "$(dirname "$0")"
SLURM_NTASKS=8

# rm -rf ./0
./Allclean.sh
cp -rf 0.org 0


# blockMesh
# system/updateParDict.sh -p $SLURM_NTASKS

# echo "MESH_START_TIME: $(date)"

# mpirun -np $SLURM_NTASKS redistributePar -decompose -parallel
# mpirun -np $SLURM_NTASKS snappyHexMesh -parallel -overwrite
# mpirun -np $SLURM_NTASKS redistributePar -reconstruct -constant -parallel


# echo "DECOMPOSE_START_TIME: $(date)"

# mpirun -np $SLURM_NTASKS redistributePar -decompose -parallel
# echo "SOLVE_START_TIME: $(date)"

# mpirun -np $SLURM_NTASKS rhoCentralFoam -parallel
# echo "RECONSTRUCT_START_TIME: $(date)"

# mpirun -np $SLURM_NTASKS redistributePar -reconstruct -constant -parallel
# echo "RECONSTRUCT_END_TIME: $(date)"


blockMesh

snappyHexMesh -overwrite
decomposePar
mpirun -np $SLURM_NTASKS foamRun -parallel
#reconstructPar
