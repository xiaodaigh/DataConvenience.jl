# export replace_onehot!
#
# using DataFrames: select!, Not

"""
    replace_onehot!(df, col) = begin

Replace `col` with the onehot representation
"""
# replace_onehot!(df, col) = begin
    # x = df[!, col]
    # oh = onehotbatch(x.refs, 1:length(x.pool))
    # for (i, n) in enumerate(string(col).*string.(x.pool.index))
    #     df[!, Symbol(n)] = oh[i, :]
    # end
    # select!(df, Not(col))
    # df
# end
