"""
    mesh_basic(coordinates_min, coordinates_max, n_points_x, n_points_y)

Create points in a regular grid.
"""
function mesh_basic(coordinates_min, coordinates_max, n_points_x, n_points_y)
    dx = (coordinates_max[1] - coordinates_min[1]) / (n_points_x - 1)
    dy = (coordinates_max[2] - coordinates_min[2]) / (n_points_y - 1)

    # Number of points:
    # Tensorproduct: n_points_x * n_points_y
    # Add for half the rows (rounded off) one point each
    n_points = n_points_x * n_points_y + div(n_points_y - n_points_y % 2, 2)
    points = Matrix{eltype(coordinates_min)}(undef, 2, n_points)

    count = 1
    for j in 1:n_points_y
        for i in 1:n_points_x
            points[1, count] = coordinates_min[1] + (i - 1) * dx
            points[2, count] = coordinates_min[2] + (j - 1) * dy
            if j % 2 == 0 && i != 1
                points[1, count] -= 0.5dx
            end
            count += 1
            if j % 2 == 0 && i == n_points_x
                points[1, count] = points[1, count - 1] + 0.5dx
                points[2, count] = points[2, count - 1]
                count += 1
            end
        end
    end

    return points
end
