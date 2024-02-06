using Smesh

# Create data points
coordinates_min = [0.0, 0.0]
coordinates_max = [1.0, 1.0]
n_points_x = 4
n_points_y = 5
data_points = mesh_basic(coordinates_min, coordinates_max, n_points_x, n_points_y)

# Create triangulation
vertices = build_delaunay_triangulation(data_points; verbose = true)

neighbors = delaunay_compute_neighbors(data_points, vertices)
