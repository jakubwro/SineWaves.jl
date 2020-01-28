# SineWave.jl

In this tutorial I will show how to add [binary dependency](https://github.com/jakubwro/sinewave) to Julia using [BinaryBuilder.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl) package.

## Ensure BianaryBuilder.jl is installed and up to date

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

## Create build recipe (build_tarballs.jl)

To create `build_tarballs.jl` script you might want to use run_wizard() function. Let's do that step by step.

1. Run the Wizard
```
julia> using BinaryBuilder
julia> run_wizard()
```

3. Select platforms

You can limit build to some specific platforms.
```
			# Step 1: Select your platforms

Make a platform selection
 > All Supported Platforms
   Select by Operating System
   Fully Custom Platform Choice
```

4. Select C library github repository

```
			# Step 2a: Obtain the source code

Please enter a URL (git repository or compressed archive) containing the source code to build:
> https://github.com/jakubwro/sinewave
```

```
You have selected a git repository. Please enter a branch, commit or tag to use.
Please note that for reproducability, the exact commit will be recorded,
so updates to the remote resource will not be used automatically;
you will have to manually update the recorded commit.
> master
```

Then the Wizard can will ask if you want to include additional sources or binary dependencies but I am going to skip that by answering `N`.

5. Binary dependencies

```
			# Step 2b: Obtain binary dependencies (if any)

Do you require any (binary) dependencies?  [y/N]: N
```

6. Enter name of the original C project. In my case it `sinewave`
```
Enter a name for this project.  This will be used for filenames:
> sinewave
```

7. Enter versoin of the project.

It should be 0.0.1, 0.1.0 or 1.0.0 for the first time (TODO: is that true?)
```
Enter a version number for this project:
> 0.1.0
```

8. Sandbox shell

Now you'll be moved to a sandbox shell. There you should type commands to build shared libraries and copy them to predefined $libdir and $bindir directories. In my case Makefile handles that itself, so the only things I need to do is to enter source code directory and run `make install`

```
sandbox:${WORKSPACE}/srcdir # cd sinewave/
sandbox:${WORKSPACE}/srcdir/sinewave # make install
cc -I. -std=gnu99 -shared -fPIC -o libsinewave.so sinewave.c -lm
cc -I. -std=gnu99 -o sine libsinewave.so examples/fill_and_print_buffer.c -lm
mkdir -p /workspace/destdir/bin
mkdir -p /workspace/destdir/lib
cp libsinewave.so /workspace/destdir/lib
cp sine /workspace/destdir/bin
```

After you finish press CTRL+D to quit sandbox. All you typed was recorded and will be stored in the result build recipe. There is an option to edit the script in vi, so you can delete unnecessary commands.

9. After this step you need to select artifacts that you want to deploy. Despite that there is also executable generated, I am insterested in deploying just the library

```
			# Step 4: Select build products

The build has produced several libraries and executables.
Please select which of these you want to consider `products`.
These are generally those artifacts you will load or use from julia.

[press: d=done, a=all, n=none]
   [ ] bin/sine
 > [X] lib/libsinewave.so
```

Provide a name for each of your artifacts. This name will be exported from jll project and you will need to specify it in ccall.

```
Please provide a unique variable name for each build artifact:
lib/libsinewave.so:
> libsinewave
```

10. Testing the build recipe against all specified targets

Now the script will be tested against all build targets in sandboxes. If something will be wrong, you'll be moved to interactive shell to provide proper seqence of commands for the failing build.

11. Deployment of build recipe.

Standard place to keep build recipes is [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil) repository. Anyway, for tutorial purpose I am not going to deploy there. Local file suits me more for now.

```
			# Step 7: Deployment

How should we deploy this build recipe?
   Open a pull request against the community buildtree, Yggdrasil
   Write to a local file
 > Print to stdout
```

## Build tarballs and deploy jll project

Now time to generate jll package. It will wrap C binaries and allow import them to other projects with Julia's package manager (Pkg)

1. Get familiar with options of the script with `julia build_tarballs.jl --help` command
2. Create empty repo named `sinewave_jll` on github

Normally binary dependencies are hold in [JuliaBinaryWrappers](https://github.com/JuliaBinaryWrappers/) organisation. If you are going to share your binaries with a wider audience you should consider depoying it there instead of your personal account.

3. Deploy JLL package and tarballs to the newly reated repository


```
$ julia build_tarballs.jl --deploy=jakubwro/sinewave_jll
```

The script will ask you for gihub user and password to generate an access token.
If you are not comfortable with typing a password, you can set the token in a variable before running the script.

```
$ export GITHUB_TOKEN={put your access token here}
$ julia build_tarballs.jl --deploy=jakubwro/sinewave_jll
```

When script is done JLL module is pushed to your repository and tarballs are visible in [the releases tab](https://github.com/jakubwro/sinewave_jll/releases).

## Using JLL wrappers in a module

The last step is to use JLL generated binary wrappers to expose a more Julia style API.

First let's create new project needs to be generated with Pkg and add sinewave_jll binary wrapper as a dependency

```
(v1.3) pkg> generate SineWave
(v1.3) pkg> activate SineWave
(v1.3) pkg> add sinewave_jll
```

Original [C library](https://github.com/jakubwro/sinewave/blob/master/sinewave.h) contains a simple struct and 2 functions:
-   `init` to set values of the internal structure for given frequency
-   `fill` to put consecutive values of the waveform generator

Insetead of mapping `init` function directly I will create a Julia structure corresponding to the C structure. Due to the fact that Julia uses the same memory layout, there is no special mapping needed.

```
mutable struct Sine
    previous::Float64
    current::Float64
    cosine::Float64
end
```

Then I'll define a private constructor that calls the C `init` with ccall.

```
    function Sine(frequency::Float64, samplerate::Float64)
        sinewave = new()
        status = ccall((:init, libsinewave), Cint, (Ref{Sine}, Cdouble, Cdouble), sinewave, frequency samplerate)
        return sinewave
    end
```

Next I will map C `fill` function to Julia `fill!` function because the naming conventions for functions that modify their arguments is to add `!` to the name.

```
function fill!(buffer::Vector{Float64}, sine::Sine)
    ccall((:fill, libsinewave), Cvoid, (Ref{Sine}, Ptr{Float64}, Cint), sine, buffer, length(buffer))
end

```

After this we are ready to test the new module:

```
julia> using SineWave, UnicodePlots

julia> buffer = zeros(Float64, 256);

julia> s = Sine(440.0, 48000.0);

julia> SineWave.fill!(buffer, s);

julia> lineplot(buffer)
      ┌────────────────────────────────────────┐
    1 │⠀⠀⢰⠉⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡎⠙⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠋⢣⠀⠀⠀⠀⠀⠀│
      │⠀⢀⡇⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠁⠀⠀⠀⠀⠀│
      │⠀⢸⠀⠀⠀⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠈⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⡇⠀⠀⠀⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⢸⠁⠀⠀⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⢠⠃⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⡜⠀⠀⠀⠀⠸⡀⠀⠀⠀⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⣸⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⡇⠀⠀⠀⠀⠀⠘⡄⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⢣⠀⠀⠀⠀⠀⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠥⠤⠤⠤⠤⠤⠤⡧⠤⠤⠤⠤⠤⠤⡼⠤⠤⠤⠤⠤⠤⢼⠤⠤⠤⠤⠤⠤⠤⡧⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤│
      │⠀⠀⠀⠀⠀⠀⠀⢱⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠸⡀⠀⠀⠀⠀⢰⠃⠀⠀⠀⠀⠀⠀⠀⢇⠀⠀⠀⠀⠀⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⡸⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⢳⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠀⠀⢰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠀⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⢇⠀⠀⡎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡄⠀⢠⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
   -1 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣆⡰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢱⣀⡎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      └────────────────────────────────────────┘
      0                                      300

```