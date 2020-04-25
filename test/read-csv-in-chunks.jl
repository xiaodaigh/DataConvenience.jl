using DataFrames
using RDatasets
using CSV
using Test

@testset "read csv in chunks" begin
    filepath = "mtcars.csv"
    CSV.write(filepath, dataset("datasets", "mtcars"))

    # read the file 7 rows at a time
    # where the file is of size 32 rows
    chunks = CsvChunkIterator(filepath, 10)
    dfs = [DataFrame(chunk) for chunk in chunks]

    made = reduce(vcat, dfs)
    actual = CSV.read(filepath)
    @test nrow(made) == nrow(actual)
    @test ncol(made) == ncol(actual)

    # read the file 7 rows at a time
    # where the file is of size 32 rows
    chunks = CsvChunkIterator(filepath, 500)
    dfs = [DataFrame(chunk) for chunk in chunks]

    made = reduce(vcat, dfs)
    @test nrow(made) == nrow(actual)
    @test ncol(made) == ncol(actual)

    # read the file 7 rows at a time
    # where the file is of size 32 rows
    chunks = CsvChunkIterator(filepath)
    dfs = [DataFrame(chunk) for chunk in chunks]

    made = reduce(vcat, dfs)
    @test nrow(made) == nrow(actual)
    @test ncol(made) == ncol(actual)
end
