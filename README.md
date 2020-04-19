# DataConvenience

An eclectic collection of convenience functions for you.

## Data

### `cleannames!`
Somewhat similiar to R's `janitor::clean_names` so that `cleannames!(df)` cleans the names of a `DataFrame`.


### CSV Chunk Reader

You can read a CSV in chunks and apply logic to each chunk. The types of each column is inferred using the `limit` rows.

for chunk in `CsvChunkIterator`

```julia
chunk_size = 2^16 # the default value
limit = 2^16 # the number of rows to use to infer type

for chunk in CSVChunkIterator(filepath, chunk_size, limit = limit)
  df = DataFrame(chunk)
  # do something to df
end
```

The chunk iterator uses `CSV.Rows` parameters. The user can pass in `type` and `types` to dictate the types of each column e.g.

```julia
# read all column as String
for chunk in CSVChunkIterator(filepath, type=String)
  df = DataFrame(chunk)
  # do something to df
end
```

```julia
# read a three colunms csv where the column types are String, Int, Float32
for chunk in CSVChunkIterator(filepath, types=[String, Int, Float32])
  df = DataFrame(chunk)
  # do something to df
end
```


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
`StringVector(v::CategoricalVector{String})` - Convert `v::CategoricalVector` efficiently to WeakRefStrings.StringVector
