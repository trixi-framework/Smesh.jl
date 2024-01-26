module TestExamples

using Test
using Smesh

@testset verbose=true showtiming=true "test_examples.jl" begin

@testset verbose=true showtiming=true "examples/build_delaunay_triangulation.jl" begin
    @test_nowarn include("../examples/build_delaunay_triangulation.jl")
end

end # @testset "test_examples.jl"

end # module

