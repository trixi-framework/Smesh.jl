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

### Plotting ###
using Plots; gr()

# Vertices
p = scatter(data_points[1, :], data_points[2, :], legend=false, title="vertices")
display(p)

# Triangles
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
plot!(title = "triangles")
display(p)
