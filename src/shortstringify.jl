export short_stringify!

# Original code courtesy of Nils Gudat
using ShortStrings: ShortString
using Missings: passmissing
using PooledArrays

# Functions to turn String columns into ShortStrings
function short_stringify(x::AbstractVector)
    y = ShortString("a"^maximum(length.(skipmissing(x))))
    return passmissing(typeof(y)).(x)
end

function short_stringify!(df::DataFrame)
    cols = unique([names(df, String); names(df, Union{Missing, String})])
    for c ∈ cols
        df[!, c] = PooledArray(short_stringify(df[!, c]))
    end
    return df
end

