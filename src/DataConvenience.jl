module DataConvenience

import WeakRefStrings:StringVector
using DataFrames: AbstractDataFrame, DataFrame, rename, dropmissing
using CategoricalArrays
using Statistics
using Missings: nonmissingtype

import Statistics:cor
export cor, dfcor, @replicate, StringVector


include("cate-arrays.jl")
include("CCA.jl")
include("janitor.jl")
include("dfcor.jl")
include("onehot.jl")
include("create-missing.jl")
include("read-csv-in-chunks.jl")
include("fsort-dataframes.jl")
include("fast-missing-count.jl")
include("sample.jl")
# include("shortstringify.jl")

# head(df::AbstractDataFrame) = first(df, 10)
#
# tail(df::AbstractDataFrame) = last(df, 10)
"""
    @replicate n expr

Replicate the expression `n` times

## Example
```julia
using DataConvenience, Random
@replicate 10 randstring(8) # returns 10 random length 8 strings
```
"""
macro replicate(n, expr)
    :([$(esc(expr)) for i=1:$(esc(n))])
end


end # module
