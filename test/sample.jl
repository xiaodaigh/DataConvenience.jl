using DataFrames
using DataConvenience

sample(DataFrame(a=1:100), 10)

sample(DataFrame(a=1:100), 0.1)

sample(DataFrame(a=1:100), 1//7)