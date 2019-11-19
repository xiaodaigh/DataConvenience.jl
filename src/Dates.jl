function parseDateTimeN(str)
    date, mmn = split(str, '.')
    date1, time1 = split(date,'T')

    time2 = parse.(Int64, split(time1, ':'))

    mmn1 = mmn * reduce(*, ["0" for i in 1:(9-length(mmn))])

    rd = reverse(digits(parse(Int, mmn1), pad = 9))

    t = reduce(vcat, [
        time2,
        parse(Int, reduce(*, string.(rd[1:3]))),
        parse(Int, reduce(*, string.(rd[4:6]))),
        parse(Int, reduce(*, string.(rd[7:9])))]
        )

    DateTimeN(Date(date1), Time(t...))
end


import Base:show

show(io::IO, dd::DateTimeN) = begin
    print(io, dd.d)
    print(io, dd.t)
end

DateTimeN(str::String) = parseDateTimeN(str)
