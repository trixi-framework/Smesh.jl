using Smesh

# Create data points
# Note: the transpose + collect is just such that we can write the matrix in human readable
# form here
data_points = collect([0.0 0.0
                       1.0 0.0
                       1.0 1.0
                       0.0 1.0]')

# Create triangulation
vertices = build_delaunay_triangulation(data_points; verbose = true)

neighbors = delaunay_compute_neighbors(data_points, vertices)
