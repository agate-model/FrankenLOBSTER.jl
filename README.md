# FrankenLOBSTER.jl

FrankenLOBSTER is a size-structured phytoplankton, zooplankton, and heterotrophic
bacterioplankton model for [Agate.jl](https://github.com/agate-model/Agate.jl).
It composes with OceanBioME's `LOBSTER` nutrient and detritus model, which
supplies nitrate, ammonium, dissolved and particulate organic matter, and the
surrounding biogeochemical processes.

FrankenLOBSTER owns the model's scientific components, processes, parameter
and settings defaults, construction interface, and scientific tests. Agate
supplies model compilation, recipe serialization, and the reusable
`NPDPlankton`/OceanBioME integration.

## Usage

```julia
using FrankenLOBSTER
using OceanBioME.Models.NutrientsPlanktonDetritusModels: LOBSTER
using Oceananigans: RectilinearGrid
using Oceananigans.Architectures: CPU

grid = RectilinearGrid(CPU(); size=(1, 1, 4), extent=(1, 1, 40))
plankton = FrankenLOBSTER.construct(; grid)
bgc = LOBSTER(grid; plankton)

plankton, recipe = FrankenLOBSTER.construct_plus_recipe(; grid)
replayed = FrankenLOBSTER.construct(recipe; grid)
```

The default community contains two phytoplankton SizeClasses (`P`), two
zooplankton SizeClasses (`Z`), and one heterotrophic bacterioplankton SizeClass
(`H`). `size_structure`, `parameters`, `settings`, `sinking_tracers`, and
`open_bottom` can be configured through `construct` and recorded in a recipe.

The existing [Agate documentation](https://agate-model.github.io/Agate.jl/dev/)
contains the end-to-end FrankenLOBSTER/OceanBioME tutorial.

## Development and tests

Until Agate v0.17.0 is registered, develop FrankenLOBSTER against the checked-out
Agate source. From a FrankenLOBSTER checkout next to `Agate.jl`:

```julia
using Pkg
Pkg.activate(".")
Pkg.develop(path="../Agate.jl")
Pkg.test()
```

The ordinary test suite covers construction, recipe replay, model settings,
OceanBioME nutrient/detritus exchange, closed nitrogen budgets, and Enzyme
parameter gradients. An optional CUDA smoke test checks the composed NPD model:

```julia
using Pkg
Pkg.activate("test/gpu")
Pkg.develop(path=".")           # use the FrankenLOBSTER repository root as cwd
Pkg.develop(path="../Agate.jl")
Pkg.instantiate()
```

Then run `julia --project=test/gpu test/gpu/smoke.jl` from the repository root.
After the Agate v0.17.0 release, the package will declare `Agate = "0.17"`
compatibility and resolve the registered dependency.

## License

MIT, with copyright terms inherited from the original Agate.jl implementation.
