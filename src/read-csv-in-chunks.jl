export CsvChunksIterator

using CSV: Rows, read
using DataFrames: DataFrame

import Base: iterate
import Base.Iterators.PartitionIterator

"""
    csv_chunks"path/to/JDFfile.jdf"

    CSV_CHUNKS("path/to/file.csv")

Define a Chunking iterator on CSV file
"""
struct CsvChunksIterator
    chunk_iterator::Base.Iterators.PartitionIterator

    CsvChunksIterator(path::String, n = 2^16) = begin
        csv_rows = CSV.Rows(filepath)
        new(Iterators.partition(csv_rows, n))
    end
end
