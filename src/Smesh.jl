module Smesh

using Preferences: @load_preference
using smesh_jll: smesh_jll

export build_delaunay_triangulation, delaunay_compute_neighbors, build_polygon_mesh, voronoi_compute_neighbors
export mesh_basic

const libsmesh = @load_preference("libsmesh", smesh_jll.libsmesh)

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

"""
    build_polygon_mesh(data_points, triangulation_vertices; mesh_type=:standard_voronoi, orthogonal_boundary_edges=true)

There are three different mesh types:
- `:standard_voronoi` => standard voronoi, but use centroid if the circumcenter lies outside the triangle
- `:centroids` => not an actual voronoi, always use centroids and not circumcenters as vertices for the mesh
- `:incenters` => not an actual voronoi, always use incenters and not circumcenters as vertices for the mesh
- `:pure_voronoi` => pur Voronoi mesh (just for experiments, should not be used for computation)

"""
function build_polygon_mesh(data_points, triangulation_vertices; mesh_type=:standard_voronoi, orthogonal_boundary_edges=true)
    mesh_type_dict = Dict(:pure_voronoi => Cint(-1), :standard_voronoi => Cint(0), :centroids => Cint(1), :incenters => Cint(2))

    array_sizes = Vector{Cint}(undef, 3) # npt_voronoi, nve_voronoi, nelem_voronoi==nnode

    npt_delaunay = size(data_points, 2)
    nelem_delaunay = size(triangulation_vertices, 2)
    nnode = npt_delaunay

    orthogonal_boundary_edges_bool = orthogonal_boundary_edges ? 1 : 0

    @ccall libsmesh.polygon_mesh_temparray_size_c(array_sizes::Ref{Cint},
                                                  triangulation_vertices::Ref{Cint},
                                                  data_points::Ref{Float64},
                                                  mesh_type_dict[mesh_type]::Cint,
                                                  orthogonal_boundary_edges_bool::Cint,
                                                  npt_delaunay::Cint,
                                                  nelem_delaunay::Cint,
                                                  nnode::Cint)::Cvoid

    npt_voronoi, nve_voronoi, nelem_voronoi = array_sizes

    voronoi_vertices_coordinates = Matrix{Cdouble}(undef, 2, npt_voronoi)
    voronoi_vertices = Array{Cint}(undef, nve_voronoi)
    voronoi_vertices_interval = Matrix{Cint}(undef, 2, nelem_voronoi)

    @ccall libsmesh.build_polygon_mesh_c(voronoi_vertices_coordinates::Ref{Float64},
                                         voronoi_vertices::Ref{Cint},
                                         voronoi_vertices_interval::Ref{Cint},
                                         triangulation_vertices::Ref{Cint},
                                         data_points::Ref{Float64},
                                         mesh_type_dict[mesh_type]::Cint,
                                         orthogonal_boundary_edges_bool::Cint,
                                         npt_delaunay::Cint,
                                         nelem_delaunay::Cint,
                                         npt_voronoi::Cint,
                                         nve_voronoi::Cint,
                                         nelem_voronoi::Cint)::Cvoid

    return voronoi_vertices_coordinates, voronoi_vertices, voronoi_vertices_interval
end

"""
"""
function voronoi_compute_neighbors(vertices, voronoi_vertices, voronoi_vertices_interval, delaunay_neighbors)
    n_vertices_voronoi = length(voronoi_vertices)
    n_elements_voronoi = size(voronoi_vertices_interval, 2)
    n_element_delaunay = size(delaunay_neighbors, 2)

    voronoi_neighbors = Vector{Cint}(undef, n_vertices_voronoi)

    @ccall libsmesh.voronoi_compute_neighbors_c(voronoi_neighbors::Ref{Cint},
                                                vertices::Ref{Cint},
                                                voronoi_vertices::Ref{Cint},
                                                voronoi_vertices_interval::Ref{Cint},
                                                n_element_delaunay::Cint,
                                                n_vertices_voronoi::Cint,
                                                n_elements_voronoi::Cint)::Cvoid

    return voronoi_neighbors
end

include("standard_meshes.jl")
end # module Smesh
