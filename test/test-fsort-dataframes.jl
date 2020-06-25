using DataFrames
using Test
using Random: randstring

@testset "sort it" begin
M = 100_000
str_base = [randstring(8) for i in 1:1_000]
df = DataFrame(int = rand(Int32, M), float=rand(M), str = rand(str_base, M))

@time df1 = sort(df, :int);
@time df2 = fsort(df, :int);
@test df1 == df2
@test df != df2

@time df1 = sort(df, :str);
@time df2 = fsort(df, :str);
@test df1 == df2
@test df != df2

@time df1 = sort(df, [:str, :float]);
@time df2 = fsort(df, [:str, :float]);
@test df1 == df2
@test df != df2
end
