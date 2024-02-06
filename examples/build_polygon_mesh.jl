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
