module Smesh

using Preferences: @load_preference, @has_preference

export build_delaunay_triangulation, delaunay_compute_neighbors

if !@has_preference("libsmesh")
    error("""
          Missing preference `libsmesh` for package Smesh.jl. Please add a
          `LocalPreferences.toml` file to your current Julia project with the following
          content, where `path/to/libsmesh.{ext}` is the path to your local build of
          libsmesh and `{ext}` is the appropriate extension for shared libraries on your
          system (e.g., `so` on Linux, `dylib` on macOS, `dll` on Windows). Afterwards,
          you need to restart Julia.

          Content of `LocalPreferences.toml` (between the '```' marks):

          ```
          [Smesh]
          libsmesh = "path/to/libsmesh.{ext}"
          ```
          """)
end
const libsmesh = @load_preference("libsmesh")

"""
"""
function build_delaunay_triangulation(data_points; shuffle = false, verbose = false)
    # Pre-allocate output array
    npoints = size(data_points, 2)
    ve_max = @ccall libsmesh.delaunay_triangulation_temparray_size_c(npoints::Cint)::Cint
    ve_out = Matrix{Cint}(undef, 3, ve_max)

    # Perform triangulation
    ntriangles = @ccall libsmesh.build_delaunay_triangulation_c(ve_out::Ref{Cint},
                                                                data_points::Ref{Float64},
                                                                npoints::Cint,
                                                                ve_max::Cint,
                                                                shuffle::Cint,
                                                                verbose::Cint)::Cint

    # Resize array to appropriate size
    # TODO: Converting to Julia `Int`s for convenience.
    ve_out = ve_out[:, 1:ntriangles]

    return ve_out
end

"""
"""
function delaunay_compute_neighbors(data_points, vertices)
    n_nodes = size(data_points, 2)
    n_elements = size(vertices, 2)
    neighbors = Matrix{Cint}(undef, 3, n_elements)

    @ccall libsmesh.delaunay_compute_neighbors_c(neighbors::Ref{Cint}, vertices::Ref{Cint},
                                                 n_elements::Cint, n_nodes::Cint)::Cvoid

    return neighbors
end
end # module Smesh
