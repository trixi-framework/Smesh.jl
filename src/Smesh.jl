module Smesh

using Preferences: @load_preference, @has_preference 

export build_delaunay_triangulation

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


function build_delaunay_triangulation(data_points; shuffle = false, verbose = false)
    # Pre-allocate output array
    npoints = size(data_points, 2)
    ve_max = @ccall libsmesh.delaunay_triangulation_temparray_size_c(npoints::Cint)::Cint
    ve_internal = Matrix{Cint}(undef, 3, ve_max)

    # Perform triangulation
    ntriangles = @ccall libsmesh.build_delaunay_triangulation_c(ve_internal::Ref{Cint},
                                                                data_points::Ref{Float64},
                                                                npoints::Cint,
                                                                ve_max::Cint,
                                                                shuffle::Cint,
                                                                verbose::Cint)::Cint

    # Copy to array of appropriate size and convert to Julia `Int`s for convenience
    ve_out = convert(Matrix{Int}, ve_internal[:, 1:ntriangles])

    return ve_out
end


"""
    greet()

Say hello to the world.
"""
greet() = print("Hello World!")

end # module Smesh
