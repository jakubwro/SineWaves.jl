# SineWaves.jl

---

In this tutorial I will show how to add [binary dependency](https://github.com/jakubwro/sinewave) to Julia using [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl) package.

| WARNING: presented procedure is not working on Windows yet!|
| --- |

## Ensure BinaryBuilder.jl is installed and up to date

1. Open Julia's REPL
2. If you have no BinaryBuilder.jl installed press `]` to enter pkg prompt and then use `add` command install the package.
```
(v1.3) pkg> add BinaryBuilder
 Resolving package versions...
  Updating `~/.julia/environments/v1.3/Project.toml`
  [12aac903] + BinaryBuilder v0.2.2
```
Otherwise update to the latest version with `up` command
```
(v1.3) pkg> up BinaryBuilder
  Updating registry at `~/.julia/registries/General`
  Updating git-repo `https://github.com/JuliaRegistries/General.git`
 Resolving package versions...
  Updating `~/.julia/environments/v1.3/Project.toml`
```

Press backspace to return to standard REPL.
