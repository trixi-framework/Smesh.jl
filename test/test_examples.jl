module TestExamples

using Test
using Smesh

@testset verbose=true showtiming=true "test_examples.jl" begin

@testset verbose=true showtiming=true "examples/dummy.jl" begin
    @test_nowarn include("../examples/dummy.jl")
end

end # @testset "test_examples.jl"

end # module

