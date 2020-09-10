using Test
using DataConvenience


x = Vector{Union{Missing, Int64}}(undef, 1_000_000)

@testset "count_missing" begin
    @test count(ismissing, x) == count_missing(x)
end
