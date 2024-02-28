module TestUnit

using Test
using Smesh

@testset verbose=true showtiming=true "test_unit.jl" begin

@testset verbose=true showtiming=true "meshes" begin
    coordinates_min = [0.0, 0.0]
    coordinates_max = [1.0, 1.0]
    @testset verbose=true showtiming=true "mesh_basic" begin
        points = mesh_basic(coordinates_min, coordinates_max, 2, 2)
        @test points == [0.0 1.0 0.0 0.5 1.0; 0.0 0.0 1.0 1.0 1.0]
    end
    @testset verbose=true showtiming=true "mesh_bisected_rectangle" begin
        points = mesh_bisected_rectangle(coordinates_min, coordinates_max, 1, 1)
        @test points == [0.0 1.0 0.0 1.0; 0.0 0.0 1.0 1.0]
    end
end

@testset verbose=true showtiming=true "build_delaunay_triangulation" begin
    data_points = collect([0.0 0.0
                           1.0 0.0
                           1.0 1.0
                           0.0 1.0]')

    @test build_delaunay_triangulation(data_points) == [3 1; 1 3; 2 4]
end

@testset verbose=true showtiming=true "delaunay_compute_neighbors" begin
    data_points = mesh_basic([0.0, 0.0], [1.0, 1.0], 2, 3)
    vertices = Cint[5  1  3  4  3  6; 7  2  1  2  4  4; 4  4  4  5  6  7]

    @testset "non-periodic" begin
        neighbors = delaunay_compute_neighbors(data_points, vertices)
        @test neighbors == [6  4  2  0  6  1;
                            4  3  5  1  0  0;
                            0  0  0  2  3  5]
    end
    @testset "periodic" begin
        neighbors = delaunay_compute_neighbors(data_points, vertices, periodicity = (true, false))
        @test neighbors == [6  4  2  3  6  1;
                            4  3  5  1  1  0;
                            5  0  4  2  3  5]
        neighbors = delaunay_compute_neighbors(data_points, vertices, periodicity = (false, true))
        @test neighbors == [6  4  2  0  6  1;
                            4  3  5  1  0  2;
                            0  6  0  2  3  5]
        neighbors = delaunay_compute_neighbors(data_points, vertices, periodicity = (true, true))
        @test neighbors == [6  4  2  3  6  1;
                            4  3  5  1  1  2;
                            5  6  4  2  3  5]
    end
end

@testset verbose=true showtiming=true "build_polygon_mesh" begin
    data_points = collect([0.0 0.0
                           1.0 0.0
                           1.0 1.0
                           0.0 1.0]')
    vertices = Cint[3 1; 1 3; 2 4]
    neighbors = Cint[0 0; 0 0; 2 1]

    voronoi_vertices_coordinates, voronoi_vertices, voronoi_vertices_interval = build_polygon_mesh(data_points, vertices)
    @test voronoi_vertices_interval == [1 7 12 18; 5 10 16 21]
end

@testset verbose=true showtiming=true "voronoi_compute_neighbors" begin
        data_points = collect([0.0 0.0
                               1.0 0.0
                               1.0 1.0
                               0.0 1.0]')
        vertices = Cint[3 1; 1 3; 2 4]
        neighbors = Cint[0 0; 0 0; 2 1]
        voronoi_vertices_coordinates, voronoi_vertices,
            voronoi_vertices_interval = build_polygon_mesh(data_points, vertices)

        @testset "non-periodic" begin
            voronoi_neighbor = voronoi_compute_neighbors(vertices, voronoi_vertices_coordinates,
                                                         voronoi_vertices, voronoi_vertices_interval,
                                                         neighbors)
            @test voronoi_neighbor == [3, 4, 0, 0, 2, 0, 1, 0, 0, 3, 0, 1, 2, 0, 0, 4, 0, 3, 0, 0, 1, 0]
        end
        @testset "periodic - no valid mesh" begin
        @test_throws AssertionError begin
                voronoi_neighbor = voronoi_compute_neighbors(vertices, voronoi_vertices_coordinates,
                                                             voronoi_vertices, voronoi_vertices_interval,
                                                             neighbors, periodicity = (true, true))
            end
        end
    @testset "periodic" begin
        data_points = mesh_basic([0.0, 0.0], [1.0, 1.0], 2, 3)
        vertices = Cint[5  1  3  4  3  6; 7  2  1  2  4  4; 4  4  4  5  6  7]
        neighbors = Cint[6  4  2  0  6  1; 4  3  5  1  0  0; 0  0  0  2  3  5]
        voronoi_vertices_coordinates, voronoi_vertices,
            voronoi_vertices_interval = build_polygon_mesh(data_points, vertices, mesh_type = :centroids)

        voronoi_neighbor = voronoi_compute_neighbors(vertices, voronoi_vertices_coordinates,
                                                     voronoi_vertices, voronoi_vertices_interval,
                                                     neighbors, periodicity = (true, true))
        @test voronoi_neighbor == [4, 3, 2, 6, 2, 0, 4, 1, 7, 1, 5, 0, 4, 6, 5, 5, 1, 0, 6, 3, 1,
                                   2, 5, 7, 4, 2, 3, 3, 7, 0, 4, 7, 1, 7, 3, 0, 4, 5, 6, 2, 6, 0]
    end
end

end # @testset "test_unit.jl"

end # module

