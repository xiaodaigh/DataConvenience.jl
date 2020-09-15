export sample

using DataFrames: AbstractDataFrame, nrow
import StatsBase: sample
using StatsBase

function StatsBase.sample(df::AbstractDataFrame, args...; kwargs...)
    rows_sampled = sample(axes(df, 1), args...; kwargs...)
    df[rows_sampled, :]
end

function StatsBase.sample(rng, df::AbstractDataFrame, args...; kwargs...)
    rows_sampled = sample(rng, axes(df, 1), args...; kwargs...)
    df[rows_sampled, :]
end

function StatsBase.sample(df::AbstractDataFrame, frac::T; kwargs...) where T <: Union{AbstractFloat, Rational}
    @assert 0 <= frac <= 1
    n = round(Int, nrow(df)*frac)
    rows_sampled = sample(axes(df, 1), n, ; kwargs...)
    df[rows_sampled, :]
end

function StatsBase.sample(rng, df::AbstractDataFrame, frac::T; kwargs...) where T <: Union{AbstractFloat, Rational}
    @assert 0 <= frac <= 1
    n = round(Int, nrow(df)*frac)
    rows_sampled = sample(rng, axes(df, 1), n; kwargs...)
    df[rows_sampled, :]
end