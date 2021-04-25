# Weave readme
using Pkg
cd("c:/git/DataConvenience/")
Pkg.activate("c:/git/DataConvenience/readme-env")
# Pkg.update()
upcheck()

using Weave

weave("README.jmd", out_path = :pwd, doctype = "github")

if false
    tangle("README.jmd")
end
