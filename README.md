# DataConvenience

An eclectic collection of convenience functions for you.

## Data

### Faster sorting for DataFrames

You can sort `DataFrame`s (in ascending order only) faster than the `sort` function by using the `fsort` function. E.g.

```
fsort(df, :col) # sort by `:col`
fsort(df, [:col1, :col2]) # sort by `:col1` and `:col2`
fsort!(df, :col) # sort by `:col` # sort in-place by `:col`
fsort!(df, [:col1, :col2]) # sort in-place by `:col1` and `:col2`
```


### Clean column names with `cleannames!`
Somewhat similiar to R's `janitor::clean_names` so that `cleannames!(df)` cleans the names of a `DataFrame`.


### Piping Convenience

#### Re-exporting Lazy.jl's `@>` `@>>` `@as` for piping convenenice
Lazy.jl has some macros for piping operations. However, it also exports the `groupby` function which will conflict with `DataFrames.groupby`. I have made it easier here so that it `using DataConvenience` will only export the macros `@> @>> @as` for use.

#### Defining `filter(::AbstractDataFrame, arg)`
DataFrames.jl doesn't define `filter(::AbstractDataFrame, arg)` and instead has `filter(arg, ::AbstractDataFrame)` only. This makes it inconsistent with other functions so I am defining `filter` where DataFrame

#### Examples
```julia
using DataConvenience
using DataFrames

df = DataFrame(a=1:8)

@> df begin
    filter(:a => ==(1))
end

@as x df begin
    filter(x, :a => ==(1))
end

```

### CSV Chunk Reader

You can read a CSV in chunks and apply logic to each chunk. The types of each column is inferred by `CSV.read`.

```julia

for chunk in CsvChunkIterator(filepath)
  # chunk is a DataFrame
  # do something to df
end
```

The chunk iterator uses `CSV.read` parameters. The user can pass in `type` and `types` to dictate the types of each column e.g.

```julia
# read all column as String
for chunk in CsvChunkIterator(filepath, type=String)
  # df is a DataFrame where each column is String
  # do something to df
end
```

```julia
# read a three colunms csv where the column types are String, Int, Float32
for chunk in CsvChunkIterator(filepath, types=[String, Int, Float32])
  # do something to df
end
```

**Note** The chunks MAY have different column types.

## Statistics & Correlations

### Canonical Correlation
The first component of Canonical Correlation.

```
canonicalcor(x, y)
```

### Correlation for `Bool`
`cor(x::Bool, y)` -  allow you to treat `Bool` as 0/1 when computing correlation

### Correlation for `DataFrames`
`dfcor(df::AbstractDataFrame, cols1=names(df), cols2=names(df), verbose=false)`

Compute correlation in a DataFrames by specifying a set of columns `cols1` vs
another set `cols2`. The cartesian product of `cols1` and `cols2`'s correlation
will be computed

## Miscellaneous

### `@replicate`
`@replicate code times` will run `code` multiple times e.g.

```julia
@replicate 10 randstring(8)
```

### StringVector
`StringVector(v::CategoricalVector{String})` - Convert `v::CategoricalVector` efficiently to `WeakRefStrings.StringVector`

### Faster count missing

There is a `count_missisng` function

```julia
x = Vector{Union{Missing, Int}}(undef, 10_000_000)

cmx = count_missing(x) # this is faster

cmx2 = countmissing(x) # this is faster

cimx = count(ismissing, x) # the way available at base


cmx == cimx # true
```

There is also the `count_non_missisng` function and `countnonmissing` is its synonym.
