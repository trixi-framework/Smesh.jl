module TestUnit

using Test
using Smesh

@testset verbose=true showtiming=true "test_unit.jl" begin

@testset verbose=true showtiming=true "build_delaunay_triangulation" begin
    data_points = collect([0.0 0.0
                           1.0 0.0
                           1.0 1.0
                           0.0 1.0]')

    @test build_delaunay_triangulation(data_points) == [3 1; 1 3; 2 4]
end

@testset verbose=true showtiming=true "delaunay_compute_neighbors" begin
    data_points = collect([0.0 0.0
                           1.0 0.0
                           1.0 1.0
                           0.0 1.0]')
    vertices = Cint[3 1; 1 3; 2 4]

    @test delaunay_compute_neighbors(data_points, vertices) == [0 0; 0 0; 2 1]
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
    voronoi_vertices_coordinates, voronoi_vertices, voronoi_vertices_interval = build_polygon_mesh(data_points, vertices)

    voronoi_neighbor = voronoi_compute_neighbors(vertices, voronoi_vertices, voronoi_vertices_interval, neighbors)
    @test voronoi_neighbor == Cint[3, 4, 0, 0, 2, 0, 1, 0, 0, 3, 0, 1, 2, 0, 0, 4, 0, 3, 0, 0, 1, 0]
end

end # @testset "test_unit.jl"

end # module

