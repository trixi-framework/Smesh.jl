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

end # @testset "test_unit.jl"

end # module

