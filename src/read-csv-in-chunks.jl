export CsvChunksIterator


using CSV
using DataFrames: DataFrame

import Base: iterate, length, IteratorSize
using Base.Iterators

"""
    csv_chunks"path/to/JDFfile.jdf"

    CSV_CHUNKS("path/to/file.csv")

Define a Chunking iterator on CSV file
"""
struct CsvChunksIterator
    chunk_iterator::Base.Iterators.PartitionIterator{T} where T

    CsvChunksIterator(path::String, n = 2^16) = begin
        csv_rows = CSV.Rows(path)
        new(Iterators.partition(csv_rows, n))
    end
end

Base.iterate(chunk_iterator::CsvChunksIterator) = Base.iterate(chunk_iterator.chunk_iterator)

Base.iterate(chunk_iterator::CsvChunksIterator, tuple) = Base.iterate(chunk_iterator.chunk_iterator, tuple)

# this is needed for `[a for a in chunk_iterator]` to work properly
Base.IteratorSize(chunk_iterator::CsvChunksIterator) = Base.SizeUnknown()
