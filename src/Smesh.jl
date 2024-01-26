module Smesh

using Preferences: @load_preference, @has_preference 
using smesh_jll: smesh_jll

export build_delaunay_triangulation

const libsmesh = @load_preference("libsmesh", smesh_jll.libsmesh)


"""
"""
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

end # module Smesh
