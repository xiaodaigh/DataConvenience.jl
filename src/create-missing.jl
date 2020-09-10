export create_missing!

using Missings: disallowmissing

"""
	create_missing!(df, col::Symbol)

Create a new column for where `col` is missing
"""
create_missing!(df, col::Symbol; prefix="", suffix = "_missing") = begin
	df[!, prefix*string(col)*suffix] = ismissing.(df[!, col])
	if eltype(df[!, col]) <: Union{String, Missing}
		df[!, col] .= disallowmissing.(coalesce.(df[!, col], "JULIA.MISSING"))
	else
		df[!, col] .= disallowmissing.(coalesce.(df[!, col], zero(eltype(df[!, col]))))
	end
	df
end
