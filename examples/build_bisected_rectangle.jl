using Smesh

# Create data points
coordinates_min = [0.0, 0.0]
coordinates_max = [1.0, 1.0]
n_elements_x = 5
n_elements_y = 5
data_points = mesh_bisected_rectangle(coordinates_min, coordinates_max, n_elements_x, n_elements_y,
                                      symmetric_shift = true)

# Create triangulation
vertices = build_delaunay_triangulation(data_points; verbose = false, shuffle = false)

neighbors = delaunay_compute_neighbors(data_points, vertices)

mesh_type = :centroids
voronoi_vertices_coordinates, voronoi_vertices,
    voronoi_vertices_interval = build_polygon_mesh(data_points, vertices, mesh_type=mesh_type)

voronoi_neighbors = voronoi_compute_neighbors(vertices, voronoi_vertices_coordinates,
                                              voronoi_vertices, voronoi_vertices_interval,
                                              neighbors, periodicity = (true, true))
