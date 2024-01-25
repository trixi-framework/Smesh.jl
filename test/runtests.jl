using Test

@time @testset verbose=true showtiming=true "Smesh.jl tests" begin
    include("test_unit.jl")
    include("test_examples.jl")
end

