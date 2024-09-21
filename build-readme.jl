# Weave readme
using Pkg
Pkg.activate("readme-env")
#upcheck()
# Pkg.update()

using Weave

weave("README.jmd", out_path = :pwd, doctype = "github")

if false
    tangle("README.jmd")
end
