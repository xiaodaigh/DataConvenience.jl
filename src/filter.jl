# import DataFrames: AbstractDataFrame, transform, combine, groupby, select, select!
# import Base.filter

# const PAIR_LHS_TYPE = Union{Symbol, AbstractVector{Symbol}}

# function Base.filter(df::AbstractDataFrame, f)
#     filter(f, df)
# end

# function DataFrames.filter(f::Pair{S, T}) where {S <: PAIR_LHS_TYPE, T}
#     df -> filter(df, f)
# end

# function DataFrames.transform(f::Pair{S, T}) where {S <: PAIR_LHS_TYPE, T}
#     df -> transform(df, f)
# end

# function DataFrames.combine(f::Pair{S, T}) where {S <: PAIR_LHS_TYPE, T}
#     df -> combine(df, f)
# end

# function DataFrames.groupby(f::Pair{S, T}) where {S <: PAIR_LHS_TYPE, T}
#     df -> groupby(df, f)
# end

# function DataFrames.select(f::Pair{S, T}) where {S <: PAIR_LHS_TYPE, T}
#     df -> select(df, f)
# end

# function DataFrames.select!(f::Pair{S, T}) where {S <: PAIR_LHS_TYPE, T}
#     df -> select!(df, f)
# end

# function DataFrames.innerjoin(df2, f::Pair{S, T}; kwargs...) where {S <: PAIR_LHS_TYPE, T}
#     df -> innerjoin(df, df2; kwargs...)
# end

# function DataFrames.leftjoin(df2, f::Pair{S, T}; kwargs...) where {S <: PAIR_LHS_TYPE, T}
#     df -> leftjoin(df, df2; kwargs...)
# end

# function DataFrames.rightjoin(df2, f::Pair{S, T}; kwargs...) where {S <: PAIR_LHS_TYPE, T}
#     df -> rightjoin(df, df2; kwargs...)
# end

# function DataFrames.outerjoin(df2, f::Pair{S, T}; kwargs...) where {S <: PAIR_LHS_TYPE, T}
#     df -> outerjoin(df, df2; kwargs...)
# end

# function DataFrames.semijoin(df2, f::Pair{S, T}; kwargs...) where {S <: PAIR_LHS_TYPE, T}
#     df -> semijoin(df, df2; kwargs...)
# end

# function DataFrames.antijoin(df2, f::Pair{S, T}; kwargs...) where {S <: PAIR_LHS_TYPE, T}
#     df -> antijoin(df, df2; kwargs...)
# end

# function DataFrames.crossjoin(df2, f::Pair{S, T}; kwargs...) where {S <: PAIR_LHS_TYPE, T}
#     df -> crossjoin(df, df2; kwargs...)
# end