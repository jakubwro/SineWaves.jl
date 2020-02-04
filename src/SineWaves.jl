
module SineWaves

using sinewave_jll

export SineWave, fill!, spectrum

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

function fill!(buffer::Vector{Float64}, sinewave::SineWave)
    ccall((:fill, libsinewave), Cvoid, (Ref{SineWave}, Ptr{Float64}, Cint), sinewave, buffer, length(buffer))
end

function spectrum(buffer::Vector{Float64})
    return ccall((:spectrum, libsinewave), Vector{Float64}, (Ptr{Float64}, Cint), buffer, length(buffer))
end

end #module