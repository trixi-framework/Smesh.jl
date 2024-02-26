module Smesh

using Preferences: @load_preference
using smesh_jll: smesh_jll

using LinearAlgebra: normalize

export build_delaunay_triangulation, delaunay_compute_neighbors
export build_polygon_mesh, voronoi_compute_neighbors
export mesh_basic

const libsmesh = @load_preference("libsmesh", smesh_jll.libsmesh)

"""
    build_delaunay_triangulation(data_points; shuffle = false, verbose = false)


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
    delaunay_compute_neighbors(data_points, vertices; periodicity = (false, false))

Calculates the neighbor connectivity for a delaunay triangulation created with
`build_delaunay_triangulation`.
- `data_points` is an array of size 2 × (number of points) with `[coordinate, point]`.
- `vertices` of size 3 × (number of triangles) describes the triangulation with the
structure `[point_index, triangle_index]`
- `periodicity` indicates whether the mesh is periodic in x or y direction.

Note: The feature of periodic meshes is experimental. Right now, it only supports straight
boundaries which are parallel to the specific axis.
"""
function delaunay_compute_neighbors(data_points, vertices; periodicity = (false, false))
    n_nodes = size(data_points, 2)
    n_elements = size(vertices, 2)
    neighbors = Matrix{Cint}(undef, 3, n_elements)

    @ccall libsmesh.delaunay_compute_neighbors_c(neighbors::Ref{Cint}, vertices::Ref{Cint},
                                                 n_elements::Cint, n_nodes::Cint)::Cvoid

    # Periodic neighbors
    delaunay_compute_periodic_neighbors!(neighbors, periodicity, data_points, vertices)

    return neighbors
end

function delaunay_compute_periodic_neighbors!(neighbors, periodicity, data_points, vertices)
    # Add neighboring elements if there are periodic boundaries
    if !any(periodicity)
        return nothing
    end

    standard_normal_vector_left = [[-1.0, 0.0], [0.0, -1.0]]
    standard_normal_vector_right = [[1.0, 0.0], [0.0, 1.0]]
    for dim in 1:2
        if periodicity[dim]
            # Initialize lists for boundary elements
            boundary_elements_left = Int[]
            boundary_faces_left = Int[]
            boundary_elements_right = Int[]
            boundary_faces_right = Int[]
            for element in axes(vertices, 2)
                for face_index in 1:3
                    if neighbors[face_index, element] == 0 # Boundary face
                        node1 = vertices[face_index % 3 + 1, element]
                        node2 = vertices[(face_index + 1) % 3 + 1, element]
                        # Get face vector
                        x_node1 = @views data_points[:, node1]
                        x_node2 = @views data_points[:, node2]
                        face = normalize(x_node2 - x_node1)
                        # Normal vector is face vector rotated clockwise by pi/2
                        normal = [face[2], -face[1]]
                        # Add element and face to list if normal vector is valid.
                        if all(isapprox.(normal, standard_normal_vector_left[dim]))
                            push!(boundary_elements_left, element)
                            push!(boundary_faces_left, face_index)
                        elseif all(isapprox.(normal, standard_normal_vector_right[dim]))
                            push!(boundary_elements_right, element)
                            push!(boundary_faces_right, face_index)
                        end
                    end
                end
            end
            # Check whether there are the same number of elements on both sides
            @assert length(boundary_elements_left) == length(boundary_elements_right) "Different number of elements at boundaries in $dim-th direction!"
            @assert length(boundary_elements_left) != 0 "No detected boundary edge in $dim-th direction!"
            # Get coordinates for sorting
            # Note: In vertices the points are ordered counterclockwise:
            # To get the lowest point on the left/bottom, we use the point with index `face_index + 2`.
            # To get the lowest point on the right/top, we use the point with index `face_index + 1`.
            coord_elements_left = [data_points[dim % 2 + 1, vertices[(boundary_faces_left[i] + 1) % 3 + 1, boundary_elements_left[i]]]
                                   for i in eachindex(boundary_elements_left)]
            coord_elements_right = [data_points[dim % 2 + 1, vertices[boundary_faces_right[i] % 3 + 1, boundary_elements_right[i]]]
                                    for i in eachindex(boundary_elements_right)]
            p_left = sortperm(coord_elements_left)
            p_right = sortperm(coord_elements_right)
            boundary_elements_left = boundary_elements_left[p_left]
            boundary_elements_right = boundary_elements_right[p_right]
            boundary_faces_left = boundary_faces_left[p_left]
            boundary_faces_right = boundary_faces_right[p_right]

            # Check whether boundary faces have the same length
            coord_elements_left = coord_elements_left[p_left]
            coord_elements_right = coord_elements_right[p_right]
            for i in 1:(length(boundary_elements_left) - 1)
                face_length_left = abs(coord_elements_left[i] - coord_elements_left[i + 1])
                face_length_right = abs(coord_elements_right[i] - coord_elements_right[i + 1])
                @assert isapprox(face_length_left, face_length_right, atol=eps()) "Length of boundary faces in $dim-th direction do not match!"
            end
            # Check length of last boundary face
            face_length_left = abs(coord_elements_left[end] - data_points[dim % 2 + 1, vertices[boundary_faces_left[end] % 3 + 1, boundary_elements_left[end]]])
            face_length_right = abs(coord_elements_right[end] - data_points[dim % 2 + 1, vertices[(boundary_faces_right[end] + 1) % 3 + 1, boundary_elements_right[end]]])
            @assert isapprox(face_length_left, face_length_right, atol=eps()) "Length of boundary faces in $dim-th direction do not match!"

            # Add neighboring elements to neighbor data structure
            for i in eachindex(boundary_elements_left)
                element_left = boundary_elements_left[i]
                element_right = boundary_elements_right[i]
                face_left = boundary_faces_left[i]
                face_right = boundary_faces_right[i]
                @assert neighbors[face_left, element_left] == 0
                @assert neighbors[face_right, element_right] == 0
                neighbors[face_left, element_left] = element_right
                neighbors[face_right, element_right] = element_left
            end
        end
    end

    return nothing
end

"""
    build_polygon_mesh(data_points, triangulation_vertices; mesh_type=:centroids, orthogonal_boundary_edges=true)

There are three different mesh types:
- `:standard_voronoi` => standard voronoi, but use centroid if the circumcenter lies outside the triangle
- `:centroids` => not an actual voronoi, always use centroids and not circumcenters as vertices for the mesh
- `:incenters` => not an actual voronoi, always use incenters and not circumcenters as vertices for the mesh
- `:pure_voronoi` => pure Voronoi mesh (just for experiments, should not be used for computation)
"""
function build_polygon_mesh(data_points, triangulation_vertices; mesh_type=:centroids, orthogonal_boundary_edges=true)
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
    voronoi_compute_periodic_neighbors!(vertices, voronoi_vertices_coordinates, voronoi_vertices,
                                        voronoi_vertices_interval, delaunay_neighbors;
                                        periodicity = (false, false))

Calculates the neighbor connectivity for a polygon mesh created with `build_polygon_mesh`.
- `vertices` defines the structure of the triangulation. An array of size 3 × (number of triangles) with `[point_index, triangle_index]`.
- `voronoi_vertices_coordinates` contains the coordinates of Voronoi vertices in `voronoi_vertices`.
- `voronoi_vertices`: All points within the polygon mesh are sorted counterclockwise for each element.
- `voronoi_vertices_interval` is an array of size 2 × (number of elements) and contains the
  starting and ending point index for every element in `voronoi_vertices`.
- `delaunay_neighbors` is the connectivity data structure created by `delaunay_compute_neighbors`.
- `periodicity` indicates whether the mesh is periodic in x or y direction.

Note: The feature of periodic meshes is experimental. Right now, it only supports straight
boundaries which are parallel to the specific axis.
"""
function voronoi_compute_neighbors(vertices, voronoi_vertices_coordinates, voronoi_vertices,
                                   voronoi_vertices_interval, delaunay_neighbors;
                                   periodicity = (false, false))
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

    # Periodic neighbors
    voronoi_compute_periodic_neighbors!(voronoi_neighbors, periodicity,
                                        voronoi_vertices_coordinates, voronoi_vertices,
                                        voronoi_vertices_interval)

    return voronoi_neighbors
end

"""
    voronoi_compute_periodic_neighbors!(voronoi_neighbors, periodicity,
                                        voronoi_vertices_coordinates, voronoi_vertices,
                                        voronoi_vertices_interval)

"""
function voronoi_compute_periodic_neighbors!(voronoi_neighbors, periodicity,
                                             voronoi_vertices_coordinates, voronoi_vertices,
                                             voronoi_vertices_interval)
    # Add neighboring elements if there are periodic boundaries
    if !any(periodicity)
        return nothing
    end

    standard_normal_vector_left = [[-1.0, 0.0], [0.0, -1.0]]
    standard_normal_vector_right = [[1.0, 0.0], [0.0, 1.0]]
    for dim in 1:2
        if periodicity[dim]
            # Initialize lists for boundary elements
            boundary_elements_left = Int[]
            boundary_faces_left = Int[]
            boundary_elements_right = Int[]
            boundary_faces_right = Int[]
            for element in axes(voronoi_vertices_interval, 2)
                face_index_start = voronoi_vertices_interval[1, element]
                face_index_end = voronoi_vertices_interval[2, element]
                for face_index in face_index_start:face_index_end
                    if voronoi_neighbors[face_index] == 0 # Boundary face
                        node1 = voronoi_vertices[face_index]
                        if face_index < face_index_end
                            node2 = voronoi_vertices[face_index + 1]
                        else
                            node2 = voronoi_vertices[face_index_start]
                        end
                        # Get face vector
                        x_node1 = @views voronoi_vertices_coordinates[:, node1]
                        x_node2 = @views voronoi_vertices_coordinates[:, node2]
                        face = normalize(x_node2 - x_node1)
                        # Normal vector is face vector rotated clockwise by pi/2
                        normal = [face[2], -face[1]]
                        # Add element and face to list if normal vector is valid.
                        if all(isapprox.(normal, standard_normal_vector_left[dim]))
                            push!(boundary_elements_left, element)
                            push!(boundary_faces_left, face_index)
                        elseif all(isapprox.(normal, standard_normal_vector_right[dim]))
                            push!(boundary_elements_right, element)
                            push!(boundary_faces_right, face_index)
                        end
                    end
                end
            end
            # Check whether there are the same number of elements on both sides
            @assert length(boundary_elements_left) == length(boundary_elements_right) "Different number of elements at boundaries in $dim-th direction!"
            @assert length(boundary_elements_left) != 0 "No detected boundary edge in $dim-th direction!"
            # Get coordinates for sorting
            # Note: In voronoi_vertices the points are ordered counterclockwise:
            # To get the lowest point on the left/bottom, we use the end point of the face.
            # To get the lowest point on the right/top, we use the start point of the face.
            coord_elements_left = [voronoi_vertices_coordinates[dim % 2 + 1, voronoi_vertices[boundary_faces_left[i] + 1]]
                                                                for i in eachindex(boundary_elements_left)]
            coord_elements_right = [voronoi_vertices_coordinates[dim % 2 + 1, voronoi_vertices[boundary_faces_right[i]]]
                                                                 for i in eachindex(boundary_elements_right)]
            # Get sorting permutation
            p_left = sortperm(coord_elements_left)
            p_right = sortperm(coord_elements_right)
            # Permute lists
            boundary_elements_left = boundary_elements_left[p_left]
            boundary_elements_right = boundary_elements_right[p_right]
            boundary_faces_left = boundary_faces_left[p_left]
            boundary_faces_right = boundary_faces_right[p_right]

            # Check whether boundary faces have the same length
            coord_elements_left = coord_elements_left[p_left]
            coord_elements_right = coord_elements_right[p_right]
            for i in 1:(length(boundary_elements_left) - 1)
                face_length_left = abs(coord_elements_left[i] - coord_elements_left[i + 1])
                face_length_right = abs(coord_elements_right[i] - coord_elements_right[i + 1])
                @assert isapprox(face_length_left, face_length_right, atol=eps()) "Length of boundary faces in $dim-th direction do not match!"
            end
            # Check length of last boundary face.
            face_length_left = abs(coord_elements_left[end] - voronoi_vertices_coordinates[dim % 2 + 1, voronoi_vertices[boundary_faces_left[end]]])
            face_length_right = abs(coord_elements_right[end] - voronoi_vertices_coordinates[dim % 2 + 1, voronoi_vertices[boundary_faces_right[end] + 1]])
            @assert isapprox(face_length_left, face_length_right, atol=eps()) "Length of boundary faces in $dim-th direction do not match!"

            # Add neighboring elements to neighbor data structure
            for i in eachindex(boundary_elements_left)
                element_left = boundary_elements_left[i]
                element_right = boundary_elements_right[i]
                face_left = boundary_faces_left[i]
                face_right = boundary_faces_right[i]
                @assert voronoi_neighbors[face_left] == 0 && voronoi_neighbors[face_right] == 0
                voronoi_neighbors[face_left] = element_right
                voronoi_neighbors[face_right] = element_left
            end
        end
    end

    return nothing
end

include("standard_meshes.jl")
end # module Smesh
