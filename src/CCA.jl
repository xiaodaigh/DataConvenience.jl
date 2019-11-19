using LinearAlgebra

export canonicalcor
function canonicalcor(x::AbstractMatrix, y::AbstractMatrix)
    ma = inv(cov(x))*cov(x, y)*inv(cov(y))*cov(y,x)
    mb = inv(cov(y))*cov(y, x)*inv(cov(x))*cov(x,y)
    evx = eigvecs(ma)
    evy = eigvecs(mb)
    abs(cor(x*evx[:, end], y*evy[:, end]))
    #[-cor(x*evx, y*evy) for (evx, evy) in zip(eachcol(evx), eachcol(evy))]
end
