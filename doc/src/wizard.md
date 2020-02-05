# Wizard

To create `build_tarballs.jl` script you might want to use run_wizard() function. Let's do that step by step.

## Run the Wizard
```
julia> using BinaryBuilder
julia> run_wizard()
```

## Select platforms

You can limit build to some specific platforms.
```
			# Step 1: Select your platforms

Make a platform selection
 > All Supported Platforms
   Select by Operating System
   Fully Custom Platform Choice
```

## Select sources

Select C library github repository

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

Then the Wizard can will ask if you want to include additional sources. I am going to skip that by answering `N`.

## Binary dependencies

`sinewave` C library has a dependency to FFTW so it needs to be specified during this step.

```
			# Step 2b: Obtain binary dependencies (if any)

Do you require any (binary) dependencies?  [y/N]: y
Enter JLL package name:
> FFTW_jll
```

## Project name
```
Enter name of the original C project. In my case it `sinewave`. This will be used for filenames:
> sinewave
```

## Project version

Enter version of the project. It should be 0.0.1, 0.1.0 or 1.0.0 for the first time (TODO: is that true?)
```
Enter a version number for this project:
> 0.1.0
```

## Sandbox shell

Now you'll be moved to a sandbox shell. There you should type commands to build shared libraries and copy them to predefined $libdir and $bindir directories. In my case Makefile handles that itself, so the only things I need to do is to enter source code directory and run `make install`

Do not use `apk` package manager for installing binary dependencies, they should be specified in `Binary dependencies` step as JLL packages. All haders you need are in `${prefix}/include` directory and libraries required for linker should be present in `${libdir}` location. See [BinaryBuilder.jl FAQ](https://juliapackaging.github.io/BinaryBuilder.jl/dev/FAQ/#Can-I-install-packages-in-the-build-environment?-1) for more details.

```
sandbox:${WORKSPACE}/srcdir # cd sinewave/
sandbox:${WORKSPACE}/srcdir/sinewave # export CPPFLAGS="-I${prefix}/include"
sandbox:${WORKSPACE}/srcdir/sinewave # export LDFLAGS="-L${libdir}"
sandbox:${WORKSPACE}/srcdir/sinewave # make install
```

After you finish press CTRL+D to quit sandbox. All you typed was recorded and will be stored in the result build recipe. There is an option to edit the script in vi, so you can delete unnecessary commands.

## Select artifacts

Now you need to select artifacts that you want to deploy. Despite that there is also executables generated, I am insterested in deploying just the library

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

## Build other targets

Now the script will be tested against all build targets in sandboxes. If something will be wrong, you'll be moved to interactive shell to provide proper seqence of commands for the failing build.

## Deploy the build recipe

Standard place to keep build recipes is [Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil) repository. Anyway, for the tutorial purpose I am not going to deploy there. Local file suits me more for now.

```
			# Step 7: Deployment

How should we deploy this build recipe?
   Open a pull request against the community buildtree, Yggdrasil
   Write to a local file
 > Print to stdout
```
