# OpenFOAM cases

1. hsSphere_rcf - hypersonic validation case for bcs/fluid domain of HEDGE. Coarse initial mesh (just under 300k cells, solved in ~30m on 30 Rivanna cores).

## SLURM:
- `seff` <job id> gives info on cpu time and efficiency of the job once it's finished

## Adaptive Mesh Refinement (AMR)
https://www.wolfdynamics.com/training/movingbodies/OF2021/dynamicmeshes_2021_OF8.pdf
https://wiki.openfoam.com/AMR_supersonic_sphere_Re300_Ma1dot2_by_Michael_Alletto
Might need separate AMR library to refine based on pressure gradient?
https://github.com/airshaper/adaptive-mesh-refinement

## Postprocessing:

`postProcess -func <function>` ususally works, but sometimes you need to call the solver, such as for `MachNo`, the syntax for which is `<solver> -postProcess -func MachNo`

Otherwise you can specify a range of functionObjects to calculate during execution

```c++
functions    // sub-dictionary name under the system/controlDict file
{
    <userDefinedSubDictName1>
    {
        // Mandatory entries
        type                <functionObjectTypeName>;
        libs                (<libType>FunctionObjects);

        // Mandatory entries defined in <functionObjectType>
        ...

        // Optional entries defined in <functionObjectType>
        ...

        // Optional (inherited) entries
        region              region0;
        enabled             true;
        log                 true;
        timeStart           0;
        timeEnd             1000;
        executeControl      timeStep;
        executeInterval     1;
        writeControl        timeStep;
        writeInterval       1;
    }

    <userDefinedSubDictName2>
    {
        ...
    }

    ...

    <userDefinedSubDictNameN>
    {
        ...
    }
}
```
