# DataConvenience

An eclectic collection of convenience functions for your data manipulation needs.

## Data

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

```julia
using DataConvenience
using DataFrames
df = DataFrame(col = rand(1_000_000), col1 = rand(1_000_000), col2 = rand(1_000_000))

fsort(df, :col) # sort by `:col`
fsort(df, [:col1, :col2]) # sort by `:col1` and `:col2`
fsort!(df, :col) # sort by `:col` # sort in-place by `:col`
fsort!(df, [:col1, :col2]) # sort in-place by `:col1` and `:col2`
```

```
1000000×3 DataFrame
     Row │ col        col1        col2
         │ Float64    Float64     Float64
─────────┼───────────────────────────────────
       1 │ 0.46685    2.53832e-7  0.0374635
       2 │ 0.404717   4.47445e-7  0.267923
       3 │ 0.724972   1.04096e-6  0.665079
       4 │ 0.57888    1.70257e-6  0.404758
       5 │ 0.385235   2.39225e-6  0.0781073
       6 │ 0.800285   6.07543e-6  0.00295096
       7 │ 0.940843   6.69252e-6  0.704978
       8 │ 0.817557   8.0119e-6   0.574785
    ⋮    │     ⋮          ⋮           ⋮
  999994 │ 0.179524   0.999994    0.64448
  999995 │ 0.0100945  0.999994    0.953052
  999996 │ 0.214368   0.999995    0.224151
  999997 │ 0.3488     0.999996    0.91864
  999998 │ 0.930586   0.999997    0.894878
  999999 │ 0.0312132  0.999999    0.830381
 1000000 │ 0.752231   1.0         0.471916
                          999985 rows omitted
```



```julia
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
```

![](figures/README_2_1.png)



### Clean column names with `cleannames!`
Somewhat similiar to R's `janitor::clean_names` so that `cleannames!(df)` cleans the names of a `DataFrame`.

### Nesting of `DataFrame`s

Sometimes, nesting is more convenient then using `GroupedDataFrame`s

```
using DataFrames
df = DataFrame(
        a = rand(1:8, 1000),
        b = rand(1:8, 1000),
        c = rand(1:8, 1000),
    )

nested_df = nest(df, :a, :nested_df)
```

To unnest use `unnest(nested_df, :nested_df)`.

### One hot encoding

```
a = DataFrame(
  player1 = ["a", "b", "c"],
  player2 = ["d", "c", "a"]
)

# does not modify a
onehot(a, :player1)

# modfies a
onehot!(a, :player1)
```


### CSV Chunk Reader

You can read a CSV in chunks and apply logic to each chunk. The types of each column is inferred by `CSV.read`.

```julia
using DataFrames
using CSV

df = DataFrame(a = rand(1_000_000), b = rand(Int8, 1_000_000), c = rand(Int8, 1_000_000))

filepath = tempname()*".csv"
CSV.write(filepath, df)

for (i, chunk) in enumerate(CsvChunkIterator(filepath))
    println(i)
  print(describe(chunk))
end
```

```
1
3×7 DataFrame
 Row │ variable  mean       min            median     max         nmissing 
 eltype
     │ Symbol    Float64    Real           Float64    Real        Int64    
 DataType
─────┼─────────────────────────────────────────────────────────────────────
──────────
   1 │ a          0.499738     4.36023e-8   0.499524    0.999999         0 
 Float64
   2 │ b         -0.469557  -128            0.0       127                0 
 Int64
   3 │ c         -0.547335  -128           -1.0       127                0 
 Int64
```





The chunk iterator uses `CSV.read` parameters. The user can pass in `type` and `types` to dictate the types of each column e.g.

```julia
# read all column as String
for (i, chunk) in enumerate(CsvChunkIterator(filepath, types=String))
    println(i)
    print(describe(chunk))
end
```

```
1
3×7 DataFrame
 Row │ variable  mean     min                    median   max              
     nmissing  eltype
     │ Symbol    Nothing  String                 Nothing  String           
     Int64     DataType
─────┼─────────────────────────────────────────────────────────────────────
────────────────────────
   1 │ a                  0.0001001901435260244           9.997666658245752
e-5         0  String
   2 │ b                  -1                              99               
            0  String
   3 │ c                  -1                              99               
            0  String
```



```julia
# read a three colunms csv where the column types are String, Int, Float32
for chunk in CsvChunkIterator(filepath, types=[String, Int, Float32])
  print(describe(chunk))
end
```

```
3×7 DataFrame
 Row │ variable  mean       min                    median  max             
      nmissing  eltype
     │ Symbol    Union…     Any                    Union…  Any             
      Int64     DataType
─────┼─────────────────────────────────────────────────────────────────────
─────────────────────────
   1 │ a                    0.0001001901435260244          9.99766665824575
2e-5         0  String
   2 │ b         -0.469557  -128                   0.0     127             
             0  Int64
   3 │ c         -0.547335  -128.0                 -1.0    127.0           
             0  Float32
```





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

```julia
@replicate 10 8
```

```
10-element Vector{Int64}:
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

```
true
```





There is also the `count_non_missisng` function and `countnonmissing` is its synonym.
