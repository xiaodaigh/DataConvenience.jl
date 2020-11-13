# DataConvenience

An eclectic collection of convenience functions for your data manipulation needs.

## Data

### Piping Convenience

#### Re-exporting Lazy.jl's `@>` `@>>` `@as` for piping convenenice
Lazy.jl has some macros for piping operations. However, it also exports the `groupby` function which conflicts with `DataFrames.groupby`. I have made it easier here so that `using DataConvenience` will only export the macros `@>`, `@>>`,  `@as`. You can achieve the same with just Lazy.jl by doing `using Lazy: @>, @>>, @as`.

#### Defining `filter(::AbstractDataFrame, arg)`
DataFrames.jl does not define `filter(::AbstractDataFrame, arg)` and instead has `filter(arg, ::AbstractDataFrame)` only. This makes it inconsistent with the other functions so that's why I am defining `filter` with the signature `filter(::AbstractDataFrame, arg)`.

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
│ Row     │ col       │ col1       │ col2      │
│         │ Float64   │ Float64    │ Float64   │
├─────────┼───────────┼────────────┼───────────┤
│ 1       │ 0.7632    │ 4.11895e-7 │ 0.676792  │
│ 2       │ 0.832511  │ 9.90985e-7 │ 0.404122  │
│ 3       │ 0.986408  │ 9.91194e-7 │ 0.79919   │
│ 4       │ 0.994865  │ 1.40468e-6 │ 0.0211249 │
│ 5       │ 0.624364  │ 2.25037e-6 │ 0.45385   │
│ 6       │ 0.352928  │ 2.50274e-6 │ 0.856137  │
│ 7       │ 0.483774  │ 3.53432e-6 │ 0.395825  │
⋮
│ 999993  │ 0.0910381 │ 0.999992   │ 0.23127   │
│ 999994  │ 0.679958  │ 0.999994   │ 0.88958   │
│ 999995  │ 0.229172  │ 0.999994   │ 0.385509  │
│ 999996  │ 0.612217  │ 0.999994   │ 0.350795  │
│ 999997  │ 0.443417  │ 0.999996   │ 0.0680759 │
│ 999998  │ 0.697342  │ 0.999997   │ 0.888837  │
│ 999999  │ 0.672206  │ 0.999998   │ 0.257211  │
│ 1000000 │ 0.643341  │ 1.0        │ 0.0267822 │
````



````julia

df = DataFrame(col = rand(1_000_000), col1 = rand(1_000_000), col2 = rand(1_000_000))

using BenchmarkTools
fsort_1col = @belapsed fsort($df, :col) # sort by `:col`
fsort_2col = @belapsed fsort($df, [:col1, :col2]) # sort by `:col1` and `:col2`

sort_1col = @belapsed sort($df, :col) # sort by `:col`
sort_2col = @belapsed sort($df, [:col1, :col2]) # sort by `:col1` and `:col2`

using Plots
bar(["DataFrames.sort 1 col","DataFrames.sort 2 col2", "DataCon.sort 1 col","DataCon.sort 2 col2"],
    [sort_1col, sort_2col, fsort_1col, fsort_2col],
    title="DataFrames sort performance comparison",
    label = "seconds")
````


![](figures/README_3_1.png)



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
│ Row │ variable │ mean      │ min        │ median   │ max  │ nunique │ nmi
ssing │ eltype   │
│     │ Symbol   │ Float64   │ Real       │ Float64  │ Real │ Nothing │ Not
hing  │ DataType │
├─────┼──────────┼───────────┼────────────┼──────────┼──────┼─────────┼────
──────┼──────────┤
│ 1   │ a        │ 0.500052  │ 1.97181e-6 │ 0.500362 │ 1.0  │         │    
      │ Float64  │
│ 2   │ b        │ -0.373433 │ -128       │ 0.0      │ 127  │         │    
      │ Int64    │
│ 3   │ c        │ -0.433914 │ -128       │ 0.0      │ 127  │         │    
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
│ Row │ variable │ mean    │ min                    │ median  │ max        
         │ nunique │ nmissing │ eltype   │
│     │ Symbol   │ Nothing │ String                 │ Nothing │ String     
         │ Int64   │ Nothing  │ DataType │
├─────┼──────────┼─────────┼────────────────────────┼─────────┼────────────
─────────┼─────────┼──────────┼──────────┤
│ 1   │ a        │         │ 0.00010059504823334287 │         │ 9.990023351
82464e-5 │ 1000000 │          │ String   │
│ 2   │ b        │         │ -1                     │         │ 99         
         │ 256     │          │ String   │
│ 3   │ c        │         │ -1                     │         │ 99         
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
│ Row │ variable │ mean      │ min                    │ median │ max       
          │ nunique │ nmissing │ eltype   │
│     │ Symbol   │ Any       │ Any                    │ Union… │ Any       
          │ Union…  │ Nothing  │ DataType │
├─────┼──────────┼───────────┼────────────────────────┼────────┼───────────
──────────┼─────────┼──────────┼──────────┤
│ 1   │ a        │           │ 0.00010059504823334287 │        │ 9.99002335
182464e-5 │ 1000000 │          │ String   │
│ 2   │ b        │ -0.373433 │ -128                   │ 0.0    │ 127       
          │         │          │ Int64    │
│ 3   │ c        │ -0.433914 │ -128.0                 │ 0.0    │ 127.0     
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
