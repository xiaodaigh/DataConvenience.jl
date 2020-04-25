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
    first_read::Bool # reading  the first time
    column_headers::Vector{Symbol}
    csv_rows_params

    CsvChunkIterator(path::String; csv_rows_params...) = begin
         new(open(path, "r"), 2^30, true, Symbol[], csv_rows_params)
    end
end

Base.iterate(chunk_iterator::CsvChunkIterator) = begin
    bytes_read = read(chunk_iterator.file, chunk_iterator.step)
    last_newline_pos = findlast(x->x==UInt8('\n'), bytes_read)
    # no more to be read
    if isnothing(last_newline_pos) & (length(bytes_read) == 0)
        close(chunk_iterator.file)
        return nothing
    end
    if chunk_iterator.first_read
        df =
            CSV.read(
                IOBuffer(
                    @view bytes_read[1:last_newline_pos]
                );
                chunk_iterator.csv_rows_params...
            )

        chunk_iterator.column_headers = names(df)

        # make the second read not read header
        chunk_iterator.first_read = false

        # removes header options from table
        c = chunk_iterator.csv_rows_params
        d = Dict(c for c in zip(keys(c), values(c)))
        delete!(d, :header)
        chunk_iterator.csv_rows_params = (; d...)
    else
        df =
            CSV.read(
                IOBuffer(
                    @view bytes_read[1:last_newline_pos]
                );
                header=chunk_iterator.column_headers,
                chunk_iterator.csv_rows_params...
            )
    end
    return df, nothing
end

Base.iterate(chunk_iterator::CsvChunkIterator, _) = Base.iterate(chunk_iterator)

# this is needed for `[a for a in chunk_iterator]` to work properly
Base.IteratorSize(chunk_iterator::CsvChunkIterator) = Base.SizeUnknown()
