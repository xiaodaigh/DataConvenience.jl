import DataFrames: AbstractDataFrame

using DataFrames: rename!

export cleannames!, cleanname, renamedups!

"""
    cleannames!(df::DataFrame)

Uses R's `janitor::clean_names` to clean the names
"""
const ALLOWED_CHARS = vcat(vcat(vcat(Char.(-32+97:-32+97+25), Char.(97:97+25)), '_'), Char.(48:57))

renamedups!(n::AbstractVector{Symbol}) = begin
    # are the uniques?
    d = Dict{Symbol, Bool}()
    for (i, n1) in enumerate(n)
        if haskey(d, n1)
            n[i] = Symbol(string(n[i])*"_1")
            d[n[i]] = true
        else
            d[n1] = true
        end
    end
    n
end

cleanname(s) = begin
    ss = string(s)
    res = join([c in ALLOWED_CHARS ? c : '_' for c in ss])

    if res[1] in vcat(Char.(48:57))
        res = "x" * res
    end
    Symbol(res)
end

function cleannames!(df::AbstractDataFrame)
    n = names(df)
    cn = cleanname.(n)
    cn = renamedups!(cn)

    for p in Pair.(n, cn)
        rename!(df, p)
    end
    df
end
