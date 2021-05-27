"""
    cor(x::AbstractVector{Bool}, y)

    cor(y, x::AbstractVector{Bool})

Compute correlation between `Bool` and other types
"""
Statistics.cor(x::AbstractVector{Bool}, y::AbstractVector) = cor(y, Int.(x))
Statistics.cor(x::AbstractVector{Union{Bool, Missing}}, y::AbstractVector) = cor(y, passmissing(Int).(x))

"""
    dfcor(df::AbstractDataFrame, cols1=names(df), cols2=names(df), verbose=false)

Compute correlation in a DataFrames by specifying a set of columns `cols1` vs
another set `cols2`. The cartesian product of `cols1` and `cols2`'s correlation
will be computed
"""
function dfcor(df::AbstractDataFrame, cols1::Vector{T} = names(df), cols2::Vector{T} = names(df); verbose=false) where {T}
    k = 1
    l1 = length(cols1)
    l2 = length(cols2)
    res = Vector{Float32}(undef, l1*l2)
    names1 = Vector{T}(undef, l1*l2)
    names2 = Vector{T}(undef, l1*l2)
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
                    df2 = df[:,[cols1[i], cols2[j]] |> unique] |> dropmissing
                    if size(df2, 1) > 0
                        res[k] = cor(df2[!,cols1[j]], df2[!, cols2[j]])
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