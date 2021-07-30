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
     Row │ col       col1        col2
         │ Float64   Float64     Float64
─────────┼─────────────────────────────────
       1 │ 0.105124  1.55446e-6  0.100017
       2 │ 0.809754  2.25957e-6  0.616879
       3 │ 0.293     2.56491e-6  0.715032
       4 │ 0.30266   3.37852e-6  0.9849
       5 │ 0.178425  3.84486e-6  0.866251
       6 │ 0.473456  5.45083e-6  0.027404
       7 │ 0.172007  7.40482e-6  0.0996898
       8 │ 0.713334  7.86618e-6  0.32976
    ⋮    │    ⋮          ⋮           ⋮
  999994 │ 0.878301  0.99999     0.304089
  999995 │ 0.573439  0.999992    0.9735
  999996 │ 0.292394  0.999994    0.306291
  999997 │ 0.917362  0.999994    0.347056
  999998 │ 0.641369  0.999994    0.925751
  999999 │ 0.393304  0.999995    0.224786
 1000000 │ 0.169994  0.999997    0.476451
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

for chunk in CsvChunkIterator(filepath)
  print(describe(chunk))
end
```

```
3×7 DataFrame
 Row │ variable  mean       min            median    max         nmissing  
eltype
     │ Symbol    Float64    Real           Float64   Real        Int64     
DataType
─────┼─────────────────────────────────────────────────────────────────────
─────────
   1 │ a          0.499792     7.51554e-7   0.49979    0.999999         0  
Float64
   2 │ b         -0.568238  -128           -1.0      127                0  
Int64
   3 │ c         -0.411018  -128            0.0      127                0  
Int64
```





The chunk iterator uses `CSV.read` parameters. The user can pass in `type` and `types` to dictate the types of each column e.g.

```julia
# read all column as String
for chunk in CsvChunkIterator(filepath, type=String)
    print(describe(chunk))
end
```

```
3×7 DataFrame
 Row │ variable  mean     min                     median   max             
      nmissing  eltype
     │ Symbol    Nothing  String                  Nothing  String          
      Int64     DataType
─────┼─────────────────────────────────────────────────────────────────────
─────────────────────────
   1 │ a                  0.00010009729096260855           9.98587611572565
6e-5         0  String
   2 │ b                  -1                               99              
             0  String
   3 │ c                  -1                               99              
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
 Row │ variable  mean       min                     median  max            
       nmissing  eltype
     │ Symbol    Union…     Any                     Union…  Any            
       Int64     DataType
─────┼─────────────────────────────────────────────────────────────────────
──────────────────────────
   1 │ a                    0.00010009729096260855          9.9858761157256
56e-5         0  String
   2 │ b         -0.568238  -128                    -1.0    127            
              0  Int64
   3 │ c         -0.411018  -128.0                  0.0     127.0          
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
