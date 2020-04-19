using DataFrames
using RDatasets
using CSV
using Test

@testset "read csv in chunks" begin
    filepath = "mtcars.csv"
    CSV.write(filepath, dataset("datasets", "mtcars"))

    # read the file 7 rows at a time
    # where the file is of size 32 rows
    chunks = CsvChunkIterator(filepath)
    dfs = [DataFrame(chunk) for chunk in chunks]

    @test nrow(reduce(vcat, dfs)) == nrow(CSV.read(filepath))
end
