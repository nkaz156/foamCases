# Sphere validation case for HEDGE simulations
Potential case: https://www.rand.org/content/dam/rand/pubs/research_memoranda/2008/RM2678.pdf


Probably the one to go with: https://arc.aiaa.org/doi/10.2514/1.J060153

Current issues: rhocentralfoam not working with AMR - new strat: start w/ rhoPimpleFoam to refine along pressure gradients, switch to rCF to resolve the case more accurately. Potentially repeat a few times. Could also try adding the AMR script from rPF to rCF but this would require recompilation. Planning on using PyFoam to handle solver switchoff. This also makes it simple to redistribute parallel mesh regions to increase computational efficiency


Control flow:

blockMesh

decompose
snappyHexMesh (PARALLEL)
reconstruct

START LOOP (user selectable number of loops)
rPF
redistributePar
rCF
END LOOP
redistributeRar



