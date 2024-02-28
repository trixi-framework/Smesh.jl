module TestExamples

using Test
using Smesh

@testset verbose=true showtiming=true "test_examples.jl" begin

@testset verbose=true showtiming=true "examples/build_delaunay_triangulation.jl" begin
    @test_nowarn include("../examples/build_delaunay_triangulation.jl")
end

@testset verbose=true showtiming=true "examples/build_polygon_mesh.jl" begin
    @test_nowarn include("../examples/build_polygon_mesh.jl")
end

@testset verbose=true showtiming=true "examples/build_bisected_rectangle.jl" begin
    @test_nowarn include("../examples/build_bisected_rectangle.jl")
end

end # @testset "test_examples.jl"

end # module

