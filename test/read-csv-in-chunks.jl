using DataConvenience
using DataFrames
using CSV
using Test
using Random: randstring

@testset "read csv in chunks" begin
    filepath = "tmp.csv"

    M = 100_000
    str_base = [randstring(8) for i in 1:1_000]
    df = DataFrame(int = rand(Int32, M), float=rand(M), str = rand(str_base, M))

    CSV.write(filepath, df)

    # read the file 7 rows at a time
    # where the file is of size 32 rows
    chunks = CsvChunkIterator(filepath, 10)
    dfs = [DataFrame(chunk) for chunk in chunks]

    made = reduce(vcat, dfs)
    actual = CSV.read(filepath, DataFrame)
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
