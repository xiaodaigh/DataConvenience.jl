export count_not_missing, count_missing, countmissing, countnotmissing

countmissing(args...) = count_missing(args...)
countnotmissing(args...) = count_not_missing(args...)


count_not_missing(x) = length(x) - count(ismissing, x)

count_missing(x) = count(ismissing, x)

function count_not_missing(::Type{S}, x::Vector{Union{T, Missing}}) where {S, T}
    @assert isbitstype(T)
    res = zero(S)
    @inbounds for i in 1:length(x)
        res += !ismissing(x[i])
    end
    res
end

count_not_missing(x::Vector{Union{T, Missing}}) where T = count_not_missing(Int, x)

count_missing(::Type{S}, x::Vector{Union{T, Missing}}) where {S, T} =
    length(x) - count_not_missing(S, x)

count_missing(x::Vector{Union{T, Missing}}) where T = count_missing(Int, x)
