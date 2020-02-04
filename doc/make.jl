using Documenter, SineWaves

makedocs(modules = [SineWaves],
         sitename = "SineWaves.jl",
         pages = Any[
            "Home" => "index.md",
            "Using BinaryBuilder" => "builder.md",
            "C calls wrapper" => "ccalls.md",
            "Examples" => "examples.md"
        ])

deploydocs(
    repo = "github.com/jakubwro/SineWaves.jl.git",
    target = "build"
)
