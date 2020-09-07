export filter, @>, @as, @>>

import Lazy: @>, @as, @>>

import DataFrames: filter

function filter(df::AbstractDataFrame, arg; kwargs...)
    filter(arg, df; kwargs...)
end


if false
    using Pkg
    Pkg.activate("c:/git/DataConvenience")
    using DataFrames, DataConvenience
    df = DataFrame(a=1:3)

    filter(df, :a => ==(1))

    @> df begin
        filter(:a => ==(1))
    end


end