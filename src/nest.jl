export nest, unnest

using DataFrames

function nest(df::AbstractDataFrame, by, out)
    function _subdf_as_vec(sdf)
        [sdf[!, Not(by)]]
    end
    res = combine(groupby(df, by), _subdf_as_vec)

    rename!(res, names(res)[end]=>out)

    res
end

function unnest(df, val)
    tmp = [crossjoin(df[i:i, Not(val)], sdf) for (i, sdf) in enumerate(df[!, val])]
    reduce(vcat,  tmp)
end
