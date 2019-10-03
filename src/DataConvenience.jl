module DataConvenience

export nrow, ncol, head, tail, cor, dfcor, binary_info_plots

nrow(df) = size(df, 1)

ncol(df) = size(df, 2)

head(df) = first(df, 10)

tail(df) = last(df, 10)

"""
    Compute correlation in a DataFrames

"""
dfcor(df::AbstractDataFrame, cols = names(df)) = begin
    l = length(cols)

    k = 1
    res = Vector{Float32}(undef, Int(l*(l-1)/2))
    names1 = Vector{Symbol}(undef, Int(l*(l-1)/2))
    names2 = Vector{Symbol}(undef, Int(l*(l-1)/2))
    for i in 1:length(cols)
        if eltype(df[!, cols[i]]) >: String
            # do nothing
        else
            for j in i+1:length(cols)
                if eltype(df[!, cols[j]]) >: String
                    # do nothing
                else
                    println(k, " ", cols[i], " ", cols[j])
                    df2 = df[:,[cols[i], cols[j]]] |> dropmissing
                    if size(df2, 1) > 0
                        res[k] = cor(df2[!,1], df2[!, 2])
                        names1[k] = cols[i]
                        names2[k] = cols[i]
                        k+=1
                    end
                end
            end
        end
    end
    (names1, names2, res)
end


Statistics.cor(x::Vector{Bool}, y::AbstractVector) = cor(y, Int.(x))
Statistics.cor(x::Vector{Union{Bool, Missing}}, y::AbstractVector) = cor(y, passmissing(Int).(x))

dfcor(df::AbstractDataFrame; cols1 = names(df), cols2 = names(df), verbose=false) = begin
    if all(sort(cols1) .== sort(cols2))
        return dfcor(df, cols1)
    end

    k = 1
    l1 = length(cols1)
    l2 = length(cols2)
    res = Vector{Float32}(undef, l1*l2)
    names1 = Vector{Symbol}(undef, l1*l2)
    names2 = Vector{Symbol}(undef, l1*l2)
    for i in 1:l1
        icol = df[!, cols1[i]]

        if eltype(icol) >: String
            # do nothing
        else
            Threads.@threads for j in 1:l2
                if eltype(df[!, cols2[j]]) >: String
                    # do nothing
                else
                    if verbose
                        println(k, " ", cols1[i], " ", cols2[j])
                    end
                    df2 = df[:,[cols1[i], cols2[j]]] |> dropmissing
                    if size(df2, 1) > 0
                        res[k] = cor(df2[!,1], df2[!, 2])
                        names1[k] = cols1[i]
                        names2[k] = cols2[j]
                        k+=1
                    end
                end
            end
        end
    end
    (names1[1:k-1], names2[1:k-1], res[1:k-1])
end

"""
    For binary plots plot
"""
function binary_info_plots(df, target, var)
    if nonmissingtype(eltype(df[!,var])) <: Number
    else
        println("skipped $var")
        return false
    end

    dfm = dropmissing(df[:, [target, var]])

    if size(dfm, 1) == 0
        den = hline([0], title="$var: no nonmissing data ")
    else
        den = density(dfm[!, var], group=dfm[!, target], legend=:topleft, title="Density $var by $target")
        den = density!(dfm[!, var], legend=:topleft, title="Density $var by $target", label="Overall $(unique(dfm[!,target]))")
    end

    dftmp = df[:, [target, var]]
    dftmp[!, :missing] = ismissing.(dftmp[!,var])

    df1g = by(dftmp, :missing, pct_target = target => mean)

    if size(df1g, 1) == 1
        savefig(den, "plots/binaryinfo/$var.png")
    else
        mhist =
            groupedbar(df1g[!, :pct_target], group = df1g[!, :missing],
            title = "% Target == 1 by ismissing($var)",
            legendtitle = "$var is missing",
            ylab = "% Target == 1",
            legend = :bottomright,
            legendfontsize=8,
            legendtitlefontsize=10
            )

        mt = mean(df[!, target])
        StatsPlots.hline!([mt], label = "Overall Average")

        l = @layout [a; b]
        p = plot(den, mhist, layout=l)
        savefig(p, "plots/binaryinfo/$var.png")
    end

    return df1g
end

end # module
