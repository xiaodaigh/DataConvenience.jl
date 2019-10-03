module DataConvenience

using DataFrames:AbstractDataFrame
using Statistics
import Statistics:cor
using Missings:nonmissingtype

export nrow, ncol, head, tail, cor, dfcor

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



end # module
