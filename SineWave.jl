
using sinewave_jll

mutable struct SineWave
    previous::Float64
    current::Float64
    cosine::Float64
    function SineWave(frequency::Float64, samplerate::Float64)
        sinewave = new()
        status = ccall((:init, LIBSINEWAVE), Cint, (Ref{SineWave}, Cdouble, Cdouble), sinewave, frequency, samplerate)
        if (status != 0)
            error("Generator is unstable")
        end
        return sinewave
    end
end

function fill!(buffer::Vector{Float64}, sine::SineWave)
    ccall((:fill, LIBSINEWAVE), Cvoid, (Ref{SineWave}, Ptr{Vector{Float64}}, Cint), sine, buffer, length(buffer))
end
