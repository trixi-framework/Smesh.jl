using Smesh

# Create data points
corners = collect([0.0 0.0
                   1.0 0.0
                   1.0 1.0
                   0.0 1.0]')
# inner points (randomly generated)
# n_points = 10
# data_points = rand(Float64, 2, n_points)
data_points = [0.110127  0.995047  0.636537  0.942174   0.22912   0.162025  0.616885  0.376891  0.475242  0.448486;
               0.554234  0.431985  0.540326  0.0252587  0.702442  0.379256  0.80191   0.237447  0.745391  0.868326]
data_points = hcat(data_points, corners)

# Create triangulation
vertices = build_delaunay_triangulation(data_points; verbose = false)

neighbors = delaunay_compute_neighbors(data_points, vertices)

# 3 options for the mesh type
# :standard_voronoi => standard voronoi, but use centroid if the circumcenter lies outside the triangle
# :centroids        => not an actual voronoi, always use centroids and not circumcenters as vertices for the mesh
# :incenters        => not an actual voronoi, always use incenters and not circumcenters as vertices for the mesh
mesh_type = :standard_voronoi
voronoi_vertices_coordinates, voronoi_vertices, voronoi_vertices_interval = build_polygon_mesh(data_points, vertices, mesh_type=mesh_type)

voronoi_neighbors = voronoi_compute_neighbors(vertices, voronoi_vertices, voronoi_vertices_interval, neighbors)

##### Plotting
using Plots; gr()

# Vertices
p = scatter(data_points[1, :], data_points[2, :], legend=false)

# Triangles
# p = scatter(data_points, legend=false)
for element in axes(vertices, 2)
    v1 = vertices[1, element]
    v2 = vertices[2, element]
    v3 = vertices[3, element]
    x1 = data_points[:, v1]
    x2 = data_points[:, v2]
    x3 = data_points[:, v3]
    plot!(p, [x1[1], x2[1]], [x1[2], x2[2]])
    plot!(p, [x2[1], x3[1]], [x2[2], x3[2]])
    plot!(p, [x3[1], x1[1]], [x3[2], x1[2]])
end
plot!(p, title="vertices and triangles")
display(p)

# Polygon mesh
p1 = scatter(data_points[1, :], data_points[2, :], legend=false)
for element_vor in axes(voronoi_vertices_interval, 2)
    vertex_first = voronoi_vertices_interval[1, element_vor]
    vertex_last = voronoi_vertices_interval[2, element_vor]
    for i in vertex_first:(vertex_last-1)
        v1 = voronoi_vertices[i]
        v2 = voronoi_vertices[i + 1]
        x1 = voronoi_vertices_coordinates[:, v1]
        x2 = voronoi_vertices_coordinates[:, v2]
        plot!(p1, [x1[1], x2[1]], [x1[2], x2[2]])
    end
    v1 = voronoi_vertices[vertex_last]
    v2 = voronoi_vertices[vertex_first]
    x1 = voronoi_vertices_coordinates[:, v1]
    x2 = voronoi_vertices_coordinates[:, v2]
    plot!(p1, [x1[1], x2[1]], [x1[2], x2[2]], title="mesh type: $mesh_type")
end
display(p1)
