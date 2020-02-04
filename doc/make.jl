using Documenter, SineWaves

makedocs(modules = [SineWaves],
         sitename = "SineWaves.jl",
         pages = Any[
            "Home" => "index.md",
            "Wizard" => "wizard.md",
            "BinaryBuilder" => "builder.md",
            "C calls" => "ccalls.md",
            "Examples" => "examples.md"
        ])

deploydocs(
    repo = "github.com/jakubwro/SineWaves.jl.git",
    target = "build"
)
