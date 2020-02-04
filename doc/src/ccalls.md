# Using JLL wrappers in a module

The last step is to use JLL generated binary wrappers to expose a more Julia style API.

First let's create new project needs to be generated with Pkg and add sinewave_jll binary wrapper as a dependency

```
(v1.3) pkg> generate SineWave
(v1.3) pkg> activate SineWave
(v1.3) pkg> add sinewave_jll
```

Original [C library](https://github.com/jakubwro/sinewave/blob/master/sinewave.h) contains a simple struct and 3 functions:
-   `init` to set values of the internal structure for given frequency
-   `fill` to put consecutive values of the waveform generator
-   `spectrum` to get frequency content of a buffer with samples

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

Next I will map C `fill` function to Julia `Base.fill!` function. I will create new method that will take a type defined in this modula as a second parameter.

```
function fill!(buffer::Vector{Float64}, sine::Sine)
    ccall((:fill, libsinewave), Cvoid, (Ref{Sine}, Ptr{Float64}, Cint), sine, buffer, length(buffer))
end

```

`spectrum` function is a bit more complicated cause it allocates memory that needs to be freed by caller. To allow GC to do that we can use `unsafe_wrap` function. There is an optional flag `own` which tells that underlying array returned from C library must be freed by GC when no longer needed.

```
function spectrum(buffer::Vector{Float64})
    spectr = ccall((:spectrum, libsinewave), Ptr{Cdouble}, (Ptr{Float64}, Cint), buffer, length(buffer))
    len = div(length(buffer), 2) + 1
    return unsafe_wrap(Array{Float64,1}, spectr, len; own = true)
end
```
