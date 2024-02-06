using Smesh

# Create data points
coordinates_min = [0.0, 0.0]
coordinates_max = [1.0, 1.0]
n_points_x = 4
n_points_y = 5
data_points = mesh_basic(coordinates_min, coordinates_max, n_points_x, n_points_y)

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
