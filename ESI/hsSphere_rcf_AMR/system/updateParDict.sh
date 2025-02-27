#!/bin/bash
cd "$(dirname "$0")" # Change directory to host directory for runtime of script

while getopts p: OPTION # colon (:) requires an input with -p
do
    case ${OPTION} in
    p)
        numProc="${OPTARG}"
        PAR='true'
        ;;
    ?)
        echo "Invalid input argument" >&2
        exit 1
        ;;
    esac
done



cat > decomposeParDict << EOF
/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2406                                 |
|   \\  /    A nd           | Website:  www.openfoam.com                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      decomposeParDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

numberOfSubdomains  $numProc;

method  scotch;

scotchCoeffs
{
}

// ************************************************************************* //
EOF