export CsvChunkIterator
using CSV
using DataFrames: DataFrame, names

import Base: iterate, length, IteratorSize
using Base.Iterators

"""
    CsvChunkIterator("path/to/file.csv")

Define a Chunking iterator on CSV file
"""
mutable struct CsvChunkIterator
    file::IOStream
    step::Int
    column_headers::Union{Vector{String}, Vector{Symbol}}
    csv_rows_params

    CsvChunkIterator(path::String, chunk_byte_size = 2^30; csv_rows_params...) = begin
         new(open(path, "r"), chunk_byte_size, Symbol[], csv_rows_params)
    end
end

Base.iterate(chunk_iterator::CsvChunkIterator) = begin
    first_read = position(chunk_iterator.file) == 0
    bytes_read = read(chunk_iterator.file, chunk_iterator.step)
    last_newline_pos = findlast(x->x==UInt8('\n'), bytes_read)

    # no more to be read
    if isnothing(last_newline_pos) & (length(bytes_read) == 0)
        close(chunk_iterator.file)
        return nothing
    elseif isnothing(last_newline_pos)
        if eof(chunk_iterator.file)
            close(chunk_iterator.file)
            # do nothing and go to CSV.read
            last_newline_pos = length(bytes_read)
        else # increase step size
            chunk_iterator.step = 2chunk_iterator.step
            seek(chunk_iterator.file, position(chunk_iterator.file) - length(bytes_read))
            return iterate(chunk_iterator)
        end
    end

    if first_read
        df =
            CSV.read(
                IOBuffer(
                    @view bytes_read[1:last_newline_pos]
                ), DataFrame;
                chunk_iterator.csv_rows_params...
            )

        chunk_iterator.column_headers = names(df)

        # removes header options from table
        c = chunk_iterator.csv_rows_params
        d = Dict(zip(keys(c), values(c))...)
        delete!(d, :head)
        chunk_iterator.csv_rows_params = (;d...)
    else
        df =
            CSV.read(
                IOBuffer(
                    @view bytes_read[1:last_newline_pos]
                ), DataFrame;
                header=chunk_iterator.column_headers,
                chunk_iterator.csv_rows_params...
            )
    end

    new_pos = position(chunk_iterator.file) - (length(bytes_read) - last_newline_pos)
    seek(chunk_iterator.file, new_pos)
    return df, nothing
end

Base.iterate(chunk_iterator::CsvChunkIterator, _) = Base.iterate(chunk_iterator)

# this is needed for `[a for a in chunk_iterator]` to work properly
Base.IteratorSize(chunk_iterator::CsvChunkIterator) = Base.SizeUnknown()
