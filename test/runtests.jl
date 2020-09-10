using DataConvenience
using Test

include("canonicalcor.jl")
include("janitor.jl")
include("read-csv-in-chunks.jl")
include("test-fsort-dataframes.jl")
include("missing.jl")

@testset "DataConvenience.jl" begin
    # Write your own tests here.
end
