"""
    mesh_basic(coordinates_min, coordinates_max, n_points_x, n_points_y)

Creates points for a regular grid. Shifting every second column of points to avoid a simple
mesh with bisected rectangles. This results in a unique triangulation.
"""
function mesh_basic(coordinates_min, coordinates_max, n_points_x, n_points_y)
    @assert n_points_x > 1 "n_points_x has to be at least 2."
    @assert n_points_y > 1 "n_points_y has to be at least 2."

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

"""
    mesh_bisected_rectangle(coordinates_min, coordinates_max, n_points_x, n_points_y;
                            symmetric_shift = false)

Creates points in a regular manner. The resulting non-unique triangulation consists of bisected
rectangles. To allow periodic boundaries for the resulting polygon mesh, it is possible to enable
a symmetric shift.
"""
function mesh_bisected_rectangle(coordinates_min, coordinates_max, n_elements_x, n_elements_y;
                                 symmetric_shift = false)
    @assert n_elements_x > 0 "n_elements_x has to be at least 1."
    @assert n_elements_y > 0 "n_elements_y has to be at least 1."

    dx = (coordinates_max[1] - coordinates_min[1]) / n_elements_x
    dy = (coordinates_max[2] - coordinates_min[2]) / n_elements_y

    n_points = (n_elements_x + 1) * (n_elements_y + 1)
    points = Matrix{eltype(coordinates_min)}(undef, 2, n_points)
    for j in 0:n_elements_y
        for i = 0:n_elements_x
            k = j * (n_elements_x + 1) + i + 1
            points[:, k] = [coordinates_min[1] + i * dx, coordinates_min[2] + j * dy]
        end
    end

    # Symmetric shift to get unique triangulation and therefore possible periodic boundaries in
    # the polygon mesh
    if symmetric_shift
        domain_center = 0.5 * [coordinates_min[1] + coordinates_max[1],
                               coordinates_min[2] + coordinates_max[2]]
        s = [dx, dy]
        for i in axes(points, 2)
            # Do not move boundary points with boundary_distance <= 10^-6
            boundary_distance = min(abs(coordinates_min[1] - points[1, i]),
                                    abs(coordinates_max[1] - points[1, i]),
                                    abs(coordinates_min[2] - points[2, i]),
                                    abs(coordinates_max[2] - points[2, i]))
            if boundary_distance > 1.0e-8 # inner point
                d = sqrt(sum((domain_center .- points[:,i]).^2))
                points[:, i] .+= 1.0e-6 * d * s .* (domain_center .- points[:, i])
            end
        end

        if isodd(n_elements_x)
            for i in axes(points, 2)
                # Do not move boundary points with boundary_distance <= 10^-6
                boundary_distance = min(abs(coordinates_min[1] - points[1, i]),
                                        abs(coordinates_max[1] - points[1, i]),
                                        abs(coordinates_min[2] - points[2, i]),
                                        abs(coordinates_max[2] - points[2, i]))
                if boundary_distance > 1.0e-8 # inner point
                    # Only move the two most inner points columns
                    distance_center_x = abs(domain_center[1] - points[1, i])
                    if distance_center_x <= dx
                        points[1, i] += 1.0e-6 * dx
                    end
                end
            end
        end
        if isodd(n_elements_y)
            for i in axes(points, 2)
                # Do not move boundary points with boundary_distance <= 10^-6
                boundary_distance = min(abs(coordinates_min[1] - points[1, i]),
                                        abs(coordinates_max[1] - points[1, i]),
                                        abs(coordinates_min[2] - points[2, i]),
                                        abs(coordinates_max[2] - points[2, i]))
                if boundary_distance > 1.0e-8 # inner point
                    # Only move the two most inner points rows
                    distance_center_y = abs(domain_center[2] - points[2, i])
                    if distance_center_y <= dy
                        points[2, i] += 1.0e-6 * dy
                    end
                end
            end
        end
    end

    # This directly creates the connectivity of a triangulation. Every rectangle is bisected
    # in the same direction.
    # n_triangles = 2 * n_elements_x * n_elements_y
    # vertices = Matrix{Cint}(undef, 3, n_triangles)
    # k = 0
    # for j in 1:n_elements_y
    #     for i in 1:n_elements_x
    #         k = k + 1
    #         vertices[:, k] .= [(j - 1) * (n_elements_x + 1) + i,
    #                            (j - 1) * (n_elements_x + 1) + i + 1,
    #                            j * (n_elements_x + 1) + i]
    #         k = k + 1
    #         vertices[:, k] .= [(j - 1) * (n_elements_x + 1) + i + 1,
    #                            j * (n_elements_x + 1) + i + 1,
    #                            j * (n_elements_x + 1) + i]
    #     end
    # end

    return points
end