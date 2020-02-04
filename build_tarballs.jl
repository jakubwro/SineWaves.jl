# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "sinewave"
version = v"0.2.0"

# Collection of sources required to complete build
sources = [
    "https://github.com/jakubwro/sinewave.git" =>
    "193b8b776d26cac02cabd264e03b917a928769be",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd sinewave
export CPPFLAGS="-I${prefix}/include"
export LDFLAGS="-L${libdir}"
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
    "FFTW_jll"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)