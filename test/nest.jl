using DataFrames
using DataConvenience

df = DataFrame(
        a = rand(1:8, 1000),
        b = rand(1:8, 1000),
        c = rand(1:8, 1000),
    )

nest(df, :a, :meh)
unnest(nest(df, :a, :meh), :meh)
