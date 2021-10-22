

function test_one(N::Int=50, max_time::Float64=10.0)
    for _ in 1:N
        for s in [TrackAllJobs, TrackTotals]
            for λ in collect(0.1:0.1:2)
                # create init
                params = create_scen1(λ + 0.0)
                state = create_init_state(s, params)
                init = create_init_event(params, state)
                try 
                    simulate(params, state, init,max_time=max_time)
                catch
                    println("Failed in $s with λ=$λ")
                end
            end
        end
    end
    println("passed test 1")
end