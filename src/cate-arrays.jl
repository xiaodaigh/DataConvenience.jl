################################################################################
# convenient function for CategoricalArrays
################################################################################
import SortingLab:sorttwo!
using SortingLab
import StatsBase: rle
using CategoricalArrays

SortingLab.sorttwo!(x::CategoricalVector, y) = begin
    SortingLab.sorttwo!(x.refs, y)
    x, y
end

pooltype(::CategoricalPool{T,S}) where {T, S} = T,S

rle(x::CategoricalVector) = begin
   	refrle = rle(x.refs)
   	T,S = pooltype(x.pool)
   	(CategoricalArray{T, 1}(S.(refrle[1]), x.pool), refrle[2])
end

"""
    StringVector(v::CategoricalVector{String})

Convert `v::CategoricalVector` efficiently to WeakRefStrings.StringVector

## Example
```julia
using DataFrames
a  = categorical(["a","c", "a"])
a.refs
a.pool.index

# efficiently convert
sa = StringVector(a)

sa.buffer
sa.lengths
sa.offsets
```
"""
StringVector(v::CategoricalVector{S}) where S<:AbstractString = begin
    sa = StringVector(v.pool.index)
    StringVector{S}(sa.buffer, sa.offsets[v.refs], sa.lengths[v.refs])
end
