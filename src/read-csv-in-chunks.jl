export CsvChunkIterator


using CSV
using DataFrames: DataFrame

import Base: iterate, length, IteratorSize
using Base.Iterators

"""
    csv_chunks"path/to/JDFfile.jdf"

    CSV_CHUNKS("path/to/file.csv")

Define a Chunking iterator on CSV file
"""
struct CsvChunkIterator
    chunk_iterator::Base.Iterators.PartitionIterator{T} where T

    CsvChunkIterator(path::String, n = 2^16; limit = n, csv_rows_params...) = begin
        # if you have specified type or types then don't infer type
        if haskey(csv_rows_params, :type) | haskey(csv_rows_params, :types)
            # don't do anything
            csv_rows = CSV.Rows(path; csv_rows_params...)
        else
            df = CSV.read(path, limit = limit; csv_rows_params...)
            types = [eltype(col) for col in eachcol(df)]
            csv_rows = CSV.Rows(path, types = types; csv_rows_params...)
        end

        new(Iterators.partition(csv_rows, n))
    end
end

Base.iterate(chunk_iterator::CsvChunkIterator) = Base.iterate(chunk_iterator.chunk_iterator)

Base.iterate(chunk_iterator::CsvChunkIterator, tuple) = Base.iterate(chunk_iterator.chunk_iterator, tuple)

# this is needed for `[a for a in chunk_iterator]` to work properly
Base.IteratorSize(chunk_iterator::CsvChunkIterator) = Base.SizeUnknown()
