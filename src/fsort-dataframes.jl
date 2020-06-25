export fsort, fsort!

using SortingLab: fsortperm
using Tables

if VERSION >= v"1.3.0"
    import Base.Threads: @spawn
else
    macro spawn(_)
        println("DataConvenience: multithreading do not work in < Julia 1.3")
    end
end

using Base.Threads: @spawn

fsort(tbl, col::Symbol) = fsort(tbl, [col])
fsort!(tbl, col::Symbol) = fsort!(tbl, [col])

fsort(tbl, cols; threaded=true) = fsort!(copy(tbl), cols; threaded=threaded)

function fsort!(tbl, cols; threaded=true)
    @assert Tables.columnaccess(tbl)

    if threaded && (VERSION >= v"1.3")
        return _fsort_parallel!(tbl, cols)
    else
        return _fsort_single!(tbl, cols)
    end
end

function _fsort_parallel!(tbl, cols)
    @assert VERSION >= v"1.3"
    for col in reverse(cols)
        ordering = fsortperm(tbl[!, col])
        channel_lock = Channel{Bool}(length(names(tbl)))
        for c in names(tbl)
            @spawn begin
                v = tbl[!, c]
                @inbounds v .= v[ordering]
                put!(channel_lock, true)
            end
        end
        for _ in names(tbl)
            take!(channel_lock)
        end
    end
    tbl
end

function _fsort_single!(tbl, cols)
    for col in reverse(cols)
        ordering = fsortperm(tbl[!, col])
        for c in names(tbl)
            v = tbl[!, c]
            @inbounds v .= v[ordering]
        end
    end
    tbl
end