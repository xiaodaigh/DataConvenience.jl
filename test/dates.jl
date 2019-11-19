# support for nanoseconds in dates
using Dates

struct DateTimeN
    d::Date
    t::Time
end

str = "2019-10-23T12:01:15.123456789"

parseDateTimeN(str)
parseDateTimeN( "2019-10-23T12:01:15.230")

parseDateTimeN(str)
