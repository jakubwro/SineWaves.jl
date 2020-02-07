
module SineWaves

using sinewave_jll

import Base: fill!
export SineWave, spectrum

"""
    SineWave(frequency, samplerate)

Structure that has fields corresponding to C library structure. It is initialized
by calling C `init` function from a private constructor.  
"""
mutable struct SineWave
    previous::Float64
    current::Float64
    cosine::Float64
    function SineWave(frequency::Float64, samplerate::Float64)
        sinewave = new()
        status = ccall((:init, libsinewave), Cint, (Ref{SineWave}, Cdouble, Cdouble), sinewave, frequency, samplerate)
        if (status != 0)
            error("Generator is unstable for f=$frequency and fs=$samplerate")
        end
        return sinewave
    end
end

"""
    fill!(buffer, sinewave)

Fills buffer with next `sinewave` generator samples by calling `fill` function from
the C library.
"""
function fill!(buffer::Vector{Float64}, sinewave::SineWave)
    ccall((:fill, libsinewave), Cvoid, (Ref{SineWave}, Ptr{Float64}, Cint), sinewave, buffer, length(buffer))
    return buffer
end

"""
    spectrum(buffer)

Gets spectrum of `buffer` argument. It calls `spectrum` function from the C library
which allocates new array with `malloc`. This memory is reclaimed later by Julia's
garbage collector thanks to invocation of `unsafe_wrap` method with flag `own` equal
to `true`.
"""
function spectrum(buffer::Vector{Float64})
    spectr = ccall((:spectrum, libsinewave), Ptr{Cdouble}, (Ptr{Float64}, Cint), buffer, length(buffer))
    len = div(length(buffer), 2) + 1
    return unsafe_wrap(Array{Float64,1}, spectr, len; own = true)
end

end #module