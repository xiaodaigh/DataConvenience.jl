using LinearAlgebra

function CCA(x::AbstractMatrix, y::AbstractMatrix)
    ma = inv(cov(x))*cov(x, y)*inv(cov(y))*cov(y,x)
    mb = inv(cov(y))*cov(y, x)*inv(cov(x))*cov(x,y)
    cor(x*eigvecs(ma)[5], y*eigvecs(mb)[5])
end

using RCall
