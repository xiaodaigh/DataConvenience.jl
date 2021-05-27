# Weave readme
using Pkg
cd("c:/git/DataConvenience/")
Pkg.activate("c:/git/DataConvenience/readme-env")
upcheck()
# Pkg.update()

using Weave

weave("README.jmd", out_path = :pwd, doctype = "github")

if false
    tangle("README.jmd")
end

using DataFrames

a = DataFrame(a=1:3)

vscodedisplay(a)



