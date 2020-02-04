
module SineWaves

using sinewave_jll

export SineWave, fill!

mutable struct SineWave
    previous::Float64
    current::Float64
    cosine::Float64
    function SineWave(frequency::Float64, samplerate::Float64)
        sinewave = new()
        status = ccall((:init, libsinewave), Cint, (Ref{Sine}, Cdouble, Cdouble), sinewave, frequency, samplerate)
        if (status != 0)
            error("Generator is unstable for f=$frequency and fs=$samplerate")
        end
        return sinewave
    end
end

function fill!(buffer::Vector{Float64}, sinewave::SineWave)
    ccall((:fill, libsinewave), Cvoid, (Ref{Sine}, Ptr{Float64}, Cint), sinewave, buffer, length(buffer))
end

end #module