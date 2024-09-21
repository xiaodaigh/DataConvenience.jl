using DataConvenience
using DataFrames
using CSV
using Test
using Random: randstring

@testset "read csv in chunks" begin
    filepath = joinpath(tempdir(), "tmp-data-convenience-csv-chunking-test.csv")

    M = 1000
    str_base = [randstring(8) for i in 1:1_000]
    @time df = DataFrame(int = rand(Int32, M), float=rand(M), str = rand(str_base, M))

    @time CSV.write(filepath, df)

    # read the file 100 bytes at a time
    chunks = CsvChunkIterator(filepath, 100)

    dfs = [DataFrame(chunk) for chunk in chunks]

    made = reduce(vcat, dfs)
    actual = CSV.read(filepath, DataFrame)
    @test nrow(made) == nrow(actual)
    @test ncol(made) == ncol(actual)

    # read the file 500 bytes
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


    collect(CsvChunkIterator(filepath; header=0))
end
