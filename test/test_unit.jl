module TestUnit

using Test
using Smesh

@testset verbose=true showtiming=true "test_unit.jl" begin

@testset verbose=true showtiming=true "greet" begin
    @test_nowarn Smesh.greet()
end

end # @testset "test_unit.jl"

end # module

