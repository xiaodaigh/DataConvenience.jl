using Test
using RCall

@testset "DataConvenience.jl" begin
    for i in 1:100
        # Write your own tests here.
        x = rand(100, 5)
        y = rand(100, 5)

        @rput x
        @rput y
        R"""
        res = cancor(x,y)$cor[1]
        """
        @rget res
        @test res ≈  canonicalcor(x,y)
    end
end
