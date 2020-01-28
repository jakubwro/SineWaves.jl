# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "sinewave"
version = v"0.1.0"

# Collection of sources required to complete build
sources = [
    "https://github.com/jakubwro/sinewave.git" =>
    "609dbc803095d577c83478c5ef8e962613fb16a6",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd sinewave
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct("libsinewave", :libsinewave)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)