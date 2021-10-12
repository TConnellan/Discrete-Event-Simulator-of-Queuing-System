
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


function test_one(N::Int=50, max_time::Float64=10.0)

    for s in [TrackAllJobs, TrackTotals]
        for λ in [0.1]
            # create init
            params = create_scen1(λ + 0.0)
            state = create_init_state(s, params)
            init = create_init_event(params, state)
            try 
                @time simulate(params, state, init,max_time=max_time)
            catch
                println("failed")
            end
        end
    end
    println("passed test 1")
end