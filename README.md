# DataConvenience

## Corelations

### Correlation for `Bool`
`cor(x::Bool, y)` -  allow you to treat `Bool` as 0/1 when computing correlation


### Correlation for `DataFrames`
`dfcor(df::AbstractDataFrame, cols1=names(df), cols2=names(df), verbose=false)`

Compute correlation in a DataFrames by specifying a set of columns `cols1` vs
another set `cols2`. The cartesian product of `cols1` and `cols2`'s correlation
will be computed

## Miscellaneous

### `cleannames!`
Borrowed R's `janitor::clean_names` so that `cleannames!(df)` cleans the names of a `DataFrame`

### StringVector
`StringVector(v::CategoricalVector{String})` - Convert `v::CategoricalVector` efficiently to WeakRefStrings.StringVector

### `@replicate`
`@replicate code times` will run `code` multiple times e.g.

```julia
@replicate 10 randstring(8)
```
