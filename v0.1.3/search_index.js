var documenterSearchIndex = {"docs":
[{"location":"license/","page":"License","title":"License","text":"EditURL = \"https://github.com/trixi-framework/Smesh/blob/main/LICENSE.md\"","category":"page"},{"location":"license/#License","page":"License","title":"License","text":"","category":"section"},{"location":"license/","page":"License","title":"License","text":"MIT LicenseCopyright (c) 2024 The Smesh.jl AuthorsPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.","category":"page"},{"location":"reference/#API-reference","page":"API reference","title":"API reference","text":"","category":"section"},{"location":"reference/","page":"API reference","title":"API reference","text":"CurrentModule = Smesh","category":"page"},{"location":"reference/","page":"API reference","title":"API reference","text":"Modules = [Smesh]","category":"page"},{"location":"reference/#Smesh.build_delaunay_triangulation-Tuple{Any}","page":"API reference","title":"Smesh.build_delaunay_triangulation","text":"build_delaunay_triangulation(data_points; shuffle = false, verbose = false)\n\n\n\n\n\n","category":"method"},{"location":"reference/#Smesh.build_polygon_mesh-Tuple{Any, Any}","page":"API reference","title":"Smesh.build_polygon_mesh","text":"build_polygon_mesh(data_points, triangulation_vertices; mesh_type=:centroids, orthogonal_boundary_edges=true)\n\nThere are three different mesh types:\n\n:standard_voronoi => standard voronoi, but use centroid if the circumcenter lies outside the triangle\n:centroids => not an actual voronoi, always use centroids and not circumcenters as vertices for the mesh\n:incenters => not an actual voronoi, always use incenters and not circumcenters as vertices for the mesh\n:pure_voronoi => pure Voronoi mesh (just for experiments, should not be used for computation)\n\n\n\n\n\n","category":"method"},{"location":"reference/#Smesh.delaunay_compute_neighbors-Tuple{Any, Any}","page":"API reference","title":"Smesh.delaunay_compute_neighbors","text":"delaunay_compute_neighbors(data_points, vertices; periodicity = (false, false))\n\nCalculates the neighbor connectivity for a delaunay triangulation created with build_delaunay_triangulation.\n\ndata_points is an array of size 2 × (number of points) with [coordinate, point].\nvertices of size 3 × (number of triangles) describes the triangulation with the\n\nstructure [point_index, triangle_index]\n\nperiodicity indicates whether the mesh is periodic in x or y direction.\n\nNote: The feature of periodic meshes is experimental. Right now, it only supports straight boundaries which are parallel to the specific axis.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Smesh.mesh_basic-NTuple{4, Any}","page":"API reference","title":"Smesh.mesh_basic","text":"mesh_basic(coordinates_min, coordinates_max, n_points_x, n_points_y)\n\nCreates points for a regular grid. Shifting every second column of points to avoid a simple mesh with bisected rectangles. This results in a unique triangulation.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Smesh.mesh_bisected_rectangle-NTuple{4, Any}","page":"API reference","title":"Smesh.mesh_bisected_rectangle","text":"mesh_bisected_rectangle(coordinates_min, coordinates_max, n_points_x, n_points_y;\n                        symmetric_shift = false)\n\nCreates points in a regular manner. The resulting non-unique triangulation consists of bisected rectangles. To allow periodic boundaries for the resulting polygon mesh, it is possible to enable a symmetric shift.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Smesh.voronoi_compute_neighbors-NTuple{5, Any}","page":"API reference","title":"Smesh.voronoi_compute_neighbors","text":"voronoi_compute_periodic_neighbors!(vertices, voronoi_vertices_coordinates, voronoi_vertices,\n                                    voronoi_vertices_interval, delaunay_neighbors;\n                                    periodicity = (false, false))\n\nCalculates the neighbor connectivity for a polygon mesh created with build_polygon_mesh.\n\nvertices defines the structure of the triangulation. An array of size 3 × (number of triangles) with [point_index, triangle_index].\nvoronoi_vertices_coordinates contains the coordinates of Voronoi vertices in voronoi_vertices.\nvoronoi_vertices: All points within the polygon mesh are sorted counterclockwise for each element.\nvoronoi_vertices_interval is an array of size 2 × (number of elements) and contains the starting and ending point index for every element in voronoi_vertices.\ndelaunay_neighbors is the connectivity data structure created by delaunay_compute_neighbors.\nperiodicity indicates whether the mesh is periodic in x or y direction.\n\nNote: The feature of periodic meshes is experimental. Right now, it only supports straight boundaries which are parallel to the specific axis.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Smesh.voronoi_compute_periodic_neighbors!-NTuple{5, Any}","page":"API reference","title":"Smesh.voronoi_compute_periodic_neighbors!","text":"voronoi_compute_periodic_neighbors!(voronoi_neighbors, periodicity,\n                                    voronoi_vertices_coordinates, voronoi_vertices,\n                                    voronoi_vertices_interval)\n\n\n\n\n\n","category":"method"},{"location":"release-management/#Release-management","page":"Release management","title":"Release management","text":"","category":"section"},{"location":"release-management/","page":"Release management","title":"Release management","text":"To create a new release for Smesh.jl, perform the following steps:","category":"page"},{"location":"release-management/","page":"Release management","title":"Release management","text":"Make sure that all PRs and changes that you want to go into the release are merged to main and that the latest commit on main has passed all CI tests.\nDetermine the currently released version of Smesh.jl, e.g., on the release page. For this manual, we will assume that the latest release was v0.2.3.\nDecide on the next version number. We follow semantic versioning, thus each version is of the form vX.Y.Z where X is the major version, Y the minor version, and Z the patch version. In this manual, we assume that the major version is always 0, thus the decision process on the new version is as follows:\nIf the new release contains breaking changes (i.e., user code might not work as before without modifications), increase the minor version by one and set the patch version to zero. In our example, the new version should thus be v0.3.0.\nIf the new release only contains minor modifications and/or bug fixes, the minor version is kept as-is and the patch version is increased by one. In our example, the new version should thus be v0.2.4.\nEdit the version string in the Project.toml and set it to the new version. Push/merge this change to main.\nGo to GitHub and add a comment to the commit that you would like to become the new release (typically this will be the commit where you just updated the version). You can comment on a commit by going to the commit overview and clicking on the title of the commit. The comment should contain the following text:\n@JuliaRegistrator register\nWait for the magic to happen! Specifically, JuliaRegistrator will create a new PR to the Julia registry with the new release information. After a grace period of ~15 minutes, this PR will be merged automatically. A short while after, TagBot will create a new release of Smesh.jl in our GitHub repository.\nOnce the new release has been created, the new version can be obtained through the Julia package manager as usual.\nTo make sure people do not mistake the latest state of main as the latest release, we set the version in the Project.toml to a development version. The development version should be the latest released version, with the patch version incremented by one, and the -dev suffix added. For example, if you just released v0.3.0, the new development version should be v0.3.1-dev. If you just released v0.2.4, the new development version should be v0.2.5-dev.","category":"page"},{"location":"","page":"Home","title":"Home","text":"EditURL = \"https://github.com/trixi-framework/Smesh.jl/blob/main/README.md\"","category":"page"},{"location":"#Smesh.jl","page":"Home","title":"Smesh.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: Docs-stable) (Image: Docs-dev) (Image: Build Status) (Image: Coveralls) (Image: Codecov) (Image: License: MIT) (Image: DOI)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Smesh.jl is a Julia wrapper packagae for smesh, a simple Fortran package for generating and handling unstructured triangular and polygonal meshes.","category":"page"},{"location":"#Getting-started","page":"Home","title":"Getting started","text":"","category":"section"},{"location":"#Prerequisites","page":"Home","title":"Prerequisites","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"If you have not yet installed Julia, please follow the instructions for your operating system. Smesh.jl works with Julia v1.8 and later on Linux, macOS and Windows platforms.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note: On pre-Apple Silicon systems with macOS, Julia v1.10 or later is required.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Since Smesh.jl is a registered Julia package, you can install it by executing the following command in the Julia REPL:","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> import Pkg; Pkg.add(\"Smesh\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"By default, Smesh.jl uses pre-compiled binaries of the smesh package that will get automatically installed when obtaining Smesh.jl. However, you can also make use of a local smesh build.  For this, create a LocalPreferences.toml file next to your Project.toml for the project in which you use Smesh.jl. It should have the following content:","category":"page"},{"location":"","page":"Home","title":"Home","text":"On Linux:\n[Smesh]\nlibsmesh = \"<smesh-install-prefix>/lib/libsmesh.so\"\nOn macOS:\n[Smesh]\nlibsmesh = \"<smesh-install-prefix>/lib/libsmesh.dylib\"\nOn Windows:\n[Smesh]\nlibsmesh = \"<smesh-install-prefix>/bin/libsmesh.dll\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Where <smesh-install-prefix> is where you have installed the local smesh build.","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The easiest way to get started is to run one of the examples from the examples directory by includeing them in Julia, e.g.,","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using Smesh\n\njulia> include(joinpath(pkgdir(Smesh), \"examples\", \"build_delaunay_triangulation.jl\"))\nComputing Delaunay triangulation.\nTriangulation elements:          2\nTotal flipped edges:             0\nAverage search time:          1.25\nFlips/triangle:               0.00\nFlips/node:                   0.00\n3×2 Matrix{Int64}:\n 3  1\n 1  3\n 2  4\n ```\n\n\n## Referencing\nIf you use Smesh.jl in your own research, please cite this repository as follows:","category":"page"},{"location":"","page":"Home","title":"Home","text":"bibtex @misc{chiocchetti2024smesh_jl,   title={Smesh.jl: {A} {J}ulia wrapper for the Fortran package smesh to generate and handle unstructured meshes},   author={Chiocchetti, Simone and Bolm, Benjamin and Schlottke-Lakemper, Michael},   year={2024},   howpublished={\\url{https://github.com/trixi-framework/Smesh.jl}},   doi={10.5281/zenodo.10581816} } ``Please also consider citing the upstream package [smesh](https://github.com/trixi-framework/smesh) (doi:10.5281/zenodo.10579422`) itself.","category":"page"},{"location":"#Authors","page":"Home","title":"Authors","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Smesh.jl was initiated by Simone Chiocchetti (University of Cologne, Germany), Benjamin Bolm (University of Cologne, Germany), and Michael Schlottke-Lakemper (RWTH Aachen University/High-Performance Computing Center Stuttgart (HLRS), Germany) who are also its principal maintainers.","category":"page"},{"location":"#License-and-contributing","page":"Home","title":"License and contributing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Smesh.jl and smesh itself are available under the MIT license (see License). Contributions by the community are very welcome!","category":"page"}]
}