using Test, SineWaves, FFTW

@testset "SineWave constructor tests" begin
    frequency = 440.0
    samplerate = 48000.0
    delta = 2*pi*frequency/samplerate
    sinewave = SineWave(frequency, samplerate)

    @test sinewave.current ≈ 0.0
    @test sinewave.previous ≈ -sin(delta)
    @test sinewave.cosine ≈ cos(delta)

    too_hi_frequency = 40000.0
    
    @test_throws ErrorException SineWave(too_hi_frequency, samplerate)
end

@testset "fill! function tests" begin
    frequency = 440.0
    samplerate = 48000.0
    delta = 2*pi*frequency/samplerate
    N = 512

    sinewave = SineWave(frequency, samplerate)
    buffer = zeros(Float64, N)
    fill!(buffer, sinewave)
    
    @test buffer ≈ sin.(range(delta; step=delta, length = N))
end

@testset "spectrum function tests" begin
    frequency = 440.0
    samplerate = 48000.0
    delta = 2*pi*frequency/samplerate
    N = 512

    sinewave = SineWave(frequency, samplerate)
    buffer = zeros(Float64, N)
    fill!(buffer, sinewave)
    
    buffer_ft = FFTW.rfft(buffer)
    expected = abs.(buffer_ft)

    @test spectrum(buffer) ≈ expected
end
