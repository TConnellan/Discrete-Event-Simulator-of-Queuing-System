
scenario1 = NetworkParameters( L=3, 
gamma_shape = 3.0, 
λ = NaN, 
η = 4.0, 
μ_vector = ones(3),
P = [0 1.0 0;
    0 0 1.0;
    0 0 0],
Q = zeros(3,3),
p_e = [1.0, 0, 0],
K = fill(5,3))
#@show scenario1
function create_scen1(λ::Float64)
    return NetworkParameters( L=3, 
    gamma_shape = 3.0, 
    λ = λ, 
    η = 4.0, 
    μ_vector = ones(3),
    P = [0 1.0 0;
        0 0 1.0;
        0 0 0],
    Q = zeros(3,3),
    p_e = [1.0, 0, 0],
    K = fill(5,3))
end

function create_init_state(s, p::NetworkParameters)
    if (s isa TrackAllJobs)
        return TrackAllJobs(Dict{UInt64, Int64}, [Queue{UInt64}() for _ in 1:(p.L)], 0)
    else 
        return TrackTotals(zeros(p.L), 0, [Queue{UInt64}() for _ in 1:(p.L)], 0)
    end
end    

function create_init_event(p::NetworkParameters, s::State)
    dest = sample(collect(1:(p.L)), Weights(p.p_e))
    return TimedEvent(ExternalArrivalEvent(dest, s.jobCount += 1), 0.0 + rand(Gamma(1/3,3/p.η)))
end

function test_one(N::Int=50, max_time::Float64=10.0)

    for λ in 1:20
        # create init
        params = create_scen1(λ + 0.0)
        state = create_init_state(TrackAllJobs, params)
        init = create_init_event(params, state)
        try 
            simulate(params, state, init)
        catch
            println("failed")
        end
    end
    println("passed test 1")
end