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

if false
    df = DataFrame(
        a = rand(1:8, 1000),
        b = rand(1:8, 1000),
        c = rand(1:8, 1000),
    )

    nest(df, :a, :meh)
    unnest(nest(df, :a, :meh), :meh)
end

