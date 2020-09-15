# DataConvenience

An eclectic collection of convenience functions for you.

## Data

### Piping Convenience

#### Re-exporting Lazy.jl's `@>` `@>>` `@as` for piping convenenice
Lazy.jl has some macros for piping operations. However, it also exports the `groupby` function which will conflict with `DataFrames.groupby`. I have made it easier here so that it `using DataConvenience` will only export the macros `@> @>> @as` for use.

#### Defining `filter(::AbstractDataFrame, arg)`
DataFrames.jl doesn't define `filter(::AbstractDataFrame, arg)` and instead has `filter(arg, ::AbstractDataFrame)` only. This makes it inconsistent with other functions so that's why I am defining `filter` like this here.

#### Examples
````julia

using DataConvenience
using DataFrames

df = DataFrame(a=1:8)

@> df begin
    filter(:a => ==(1))
end

@as x df begin
    filter(x, :a => ==(1))
end
````


````
1×1 DataFrame
│ Row │ a     │
│     │ Int64 │
├─────┼───────┤
│ 1   │ 1     │
````





### Sampling with `sample`

You can conveniently sample a dataframe with the `sample` method

```
df = DataFrame(a=1:10)

# sample 10 rows
sample(df, 10)
```

```
# sample 10% of rows
sample(df, 0.1)
```

```
# sample 1/10 of rows
sample(df, 1//10)
```

### Faster sorting for DataFrames

You can sort `DataFrame`s (in ascending order only) faster than the `sort` function by using the `fsort` function. E.g.

````julia

using DataFrames
df = DataFrame(col = rand(1_000_000), col1 = rand(1_000_000), col2 = rand(1_000_000))

fsort(df, :col) # sort by `:col`
fsort(df, [:col1, :col2]) # sort by `:col1` and `:col2`
fsort!(df, :col) # sort by `:col` # sort in-place by `:col`
fsort!(df, [:col1, :col2]) # sort in-place by `:col1` and `:col2`
````


````
1000000×3 DataFrame
│ Row     │ col      │ col1       │ col2      │
│         │ Float64  │ Float64    │ Float64   │
├─────────┼──────────┼────────────┼───────────┤
│ 1       │ 0.320482 │ 4.77923e-7 │ 0.842944  │
│ 2       │ 0.685882 │ 1.23947e-6 │ 0.441782  │
│ 3       │ 0.916983 │ 2.58514e-6 │ 0.108329  │
│ 4       │ 0.736201 │ 2.98565e-6 │ 0.395387  │
│ 5       │ 0.843101 │ 3.41412e-6 │ 0.932144  │
│ 6       │ 0.203636 │ 3.97948e-6 │ 0.130982  │
│ 7       │ 0.782815 │ 4.28472e-6 │ 0.0088574 │
⋮
│ 999993  │ 0.252146 │ 0.999993   │ 0.249611  │
│ 999994  │ 0.495182 │ 0.999993   │ 0.158827  │
│ 999995  │ 0.11513  │ 0.999994   │ 0.776428  │
│ 999996  │ 0.531491 │ 0.999996   │ 0.258915  │
│ 999997  │ 0.706716 │ 0.999997   │ 0.441219  │
│ 999998  │ 0.176367 │ 0.999997   │ 0.26568   │
│ 999999  │ 0.484837 │ 0.999999   │ 0.652338  │
│ 1000000 │ 0.724168 │ 1.0        │ 0.658704  │
````





### Clean column names with `cleannames!`
Somewhat similiar to R's `janitor::clean_names` so that `cleannames!(df)` cleans the names of a `DataFrame`.


### CSV Chunk Reader

You can read a CSV in chunks and apply logic to each chunk. The types of each column is inferred by `CSV.read`.

````julia

using DataFrames
using CSV

df = DataFrame(a = rand(1_000_000), b = rand(Int8, 1_000_000), c = rand(Int8, 1_000_000))

filepath = tempname()*".csv"
CSV.write(filepath, df)

for chunk in CsvChunkIterator(filepath)
  print(describe(chunk))
end
````


````
3×8 DataFrame
│ Row │ variable │ mean      │ min        │ median   │ max      │ nunique │
 nmissing │ eltype   │
│     │ Symbol   │ Float64   │ Real       │ Float64  │ Real     │ Nothing │
 Nothing  │ DataType │
├─────┼──────────┼───────────┼────────────┼──────────┼──────────┼─────────┼
──────────┼──────────┤
│ 1   │ a        │ 0.500221  │ 3.28784e-7 │ 0.500533 │ 0.999998 │         │
          │ Float64  │
│ 2   │ b        │ -0.495379 │ -128       │ -1.0     │ 127      │         │
          │ Int64    │
│ 3   │ c        │ -0.508338 │ -128       │ 0.0      │ 127      │         │
          │ Int64    │
````





The chunk iterator uses `CSV.read` parameters. The user can pass in `type` and `types` to dictate the types of each column e.g.

````julia

# read all column as String
for chunk in CsvChunkIterator(filepath, type=String)
    print(describe(chunk))
end
````


````
3×8 DataFrame
│ Row │ variable │ mean    │ min                   │ median  │ max         
         │ nunique │ nmissing │ eltype   │
│     │ Symbol   │ Nothing │ String                │ Nothing │ String      
         │ Int64   │ Nothing  │ DataType │
├─────┼──────────┼─────────┼───────────────────────┼─────────┼─────────────
─────────┼─────────┼──────────┼──────────┤
│ 1   │ a        │         │ 0.0001001904864574854 │         │ 9.8532092152
04828e-7 │ 1000000 │          │ String   │
│ 2   │ b        │         │ -1                    │         │ 99          
         │ 256     │          │ String   │
│ 3   │ c        │         │ -1                    │         │ 99          
         │ 256     │          │ String   │
````



````julia

# read a three colunms csv where the column types are String, Int, Float32
for chunk in CsvChunkIterator(filepath, types=[String, Int, Float32])
  print(describe(chunk))
end
````


````
3×8 DataFrame
│ Row │ variable │ mean      │ min                   │ median │ max        
          │ nunique │ nmissing │ eltype   │
│     │ Symbol   │ Any       │ Any                   │ Union… │ Any        
          │ Union…  │ Nothing  │ DataType │
├─────┼──────────┼───────────┼───────────────────────┼────────┼────────────
──────────┼─────────┼──────────┼──────────┤
│ 1   │ a        │           │ 0.0001001904864574854 │        │ 9.853209215
204828e-7 │ 1000000 │          │ String   │
│ 2   │ b        │ -0.495379 │ -128                  │ -1.0   │ 127        
          │         │          │ Int64    │
│ 3   │ c        │ -0.508338 │ -128.0                │ 0.0    │ 127.0      
          │         │          │ Float32  │
````





**Note** The chunks MAY have different column types.

## Statistics & Correlations

### Canonical Correlation
The first component of Canonical Correlation.

```
x = rand(100, 5)
y = rand(100, 5)

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

````julia

@replicate 10 8
````


````
10-element Array{Int64,1}:
 8
 8
 8
 8
 8
 8
 8
 8
 8
 8
````





### StringVector
`StringVector(v::CategoricalVector{String})` - Convert `v::CategoricalVector` efficiently to `WeakRefStrings.StringVector`

### Faster count missing

There is a `count_missisng` function

````julia

x = Vector{Union{Missing, Int}}(undef, 10_000_000)

cmx = count_missing(x) # this is faster

cmx2 = countmissing(x) # this is faster

cimx = count(ismissing, x) # the way available at base


cmx == cimx # true
````


````
true
````





There is also the `count_non_missisng` function and `countnonmissing` is its synonym.
