# Smesh.jl

[![Docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://trixi-framework.github.io/Smesh.jl/stable)
[![Docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://trixi-framework.github.io/Smesh.jl/dev)
[![Build Status](https://github.com/trixi-framework/Smesh.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/trixi-framework/Smesh.jl/actions?query=workflow%3ACI)
[![Coveralls](https://coveralls.io/repos/github/trixi-framework/Smesh.jl/badge.svg)](https://coveralls.io/github/trixi-framework/Smesh.jl)
[![Codecov](https://codecov.io/gh/trixi-framework/Smesh.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/trixi-framework/Smesh.jl)
[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/license/mit/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10581816.svg)](https://doi.org/10.5281/zenodo.10581816)

Smesh.jl is a Julia wrapper packagae for [smesh](https://github.com/trixi-framework/smesh),
a simple Fortran package for generating and handling unstructured triangular and polygonal
meshes.


## Getting started
### Prerequisites
If you have not yet installed Julia, please [follow the instructions for your
operating system](https://julialang.org/downloads/platform/).
[Smesh.jl](https://github.com/trixi-framewor/Smesh.jl) works with Julia v1.8
and later on Linux, macOS and Windows platforms.

*Note: On pre-Apple Silicon systems with macOS, Julia v1.10 or later is required.*

### Installation
Since Smesh.jl is a registered Julia package, you can install it by executing
the following command in the Julia REPL:
```julia
julia> import Pkg; Pkg.add("Smesh")
```

By default, Smesh.jl uses pre-compiled binaries of the smesh package that will get
automatically installed when obtaining Smesh.jl. However, you can also make use of a local
smesh build.  For this, create a `LocalPreferences.toml` file next to your `Project.toml`
for the project in which you use Smesh.jl. It should have the following content:

* On Linux:
  ```toml
  [Smesh]
  libsmesh = "<smesh-install-prefix>/lib/libsmesh.so"
  ```
* On macOS:
  ```toml
  [Smesh]
  libsmesh = "<smesh-install-prefix>/lib/libsmesh.dylib"
  ```
* On Windows:
  ```toml
  [Smesh]
  libsmesh = "<smesh-install-prefix>/bin/libsmesh.dll"
  ```

Where `<smesh-install-prefix>` is where you have installed the local smesh build.

### Usage
The easiest way to get started is to run one of the examples from the
[`examples`](https://github.com/trixi-framework/Smesh.jl/tree/main/examples) directory by
`include`ing them in Julia, e.g.,
```
julia> using Smesh

julia> include(joinpath(pkgdir(Smesh), "examples", "build_delaunay_triangulation.jl"))
Computing Delaunay triangulation.
Triangulation elements:          2
Total flipped edges:             0
Average search time:          1.25
Flips/triangle:               0.00
Flips/node:                   0.00
3×2 Matrix{Int64}:
 3  1
 1  3
 2  4
 ```


## Referencing
If you use Smesh.jl in your own research, please cite this repository as follows:
```bibtex
@misc{chiocchetti2024smesh_jl,
  title={Smesh.jl: {A} {J}ulia wrapper for the Fortran package smesh to generate and handle unstructured meshes},
  author={Chiocchetti, Simone and Bolm, Benjamin and Schlottke-Lakemper, Michael},
  year={2024},
  howpublished={\url{https://github.com/trixi-framework/Smesh.jl}},
  doi={10.5281/zenodo.10581816}
}
```
Please also consider citing the upstream package
[smesh](https://github.com/trixi-framework/smesh) (`doi:10.5281/zenodo.10579422`) itself.


## Authors
Smesh.jl was initiated by
[Simone Chiocchetti](https://www.mi.uni-koeln.de/NumSim/dr-simone-chiocchetti/)
(University of Cologne, Germany),
[Benjamin Bolm](https://www.mi.uni-koeln.de/NumSim/benjamin-bolm/)
(University of Cologne, Germany), and
[Michael Schlottke-Lakemper](https://lakemper.eu) (RWTH Aachen University/High-Performance
Computing Center Stuttgart (HLRS), Germany)
who are also its principal maintainers.


## License and contributing
Smesh.jl and smesh itself are available under the MIT license (see [LICENSE.md](LICENSE.md)).
Contributions by the community are very welcome!

