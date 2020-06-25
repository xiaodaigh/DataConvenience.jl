using DataFrames
using Test

@testset "clean names " begin
    df = DataFrame(ok = 2:3, ok2 = 2:3, ok3=2:3)
    rename!(df, :ok => Symbol("ok-2"))

    @test Symbol.(names(cleannames!(df))) == [:ok_2, :ok2, :ok3]

    @test renamedups!([:ok, :ok_1, :ok_1]) == [:ok, :ok_1, :ok_1_1]
end
