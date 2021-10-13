#Here are parameters for scenarios 1, 2, 3, 4, 5 for Project 2
#For convenience they are stored in a struct, NetworkParameters

using Parameters #You need to install the Parameters.jl package: https://github.com/mauro3/Parameters.jl 
using LinearAlgebra 
using DataStructures
using Plots

"""
The main simulation function gets an initial state and an initial event
that gets things going. Optional arguments are the maximal time for the
simulation, times for logging events, and a call-back function.
"""
function simulate(params::NetworkParameters, init_state::State, init_timed_event::TimedEvent
                    ; 
                    max_time::Float64 = 10.0, 
                    log_times::Vector{Float64} = Float64[],
                    callback = (time, state) -> nothing)

    # The event queue
    priority_queue = BinaryMinHeap{TimedEvent}()



    # Put the standard events in the queue
    push!(priority_queue, init_timed_event)
    push!(priority_queue, TimedEvent(EndSimEvent(), max_time))


    # initilize the state
    state = deepcopy(init_state)
    time = 0.0

    # Callback at simulation start
    callback(time, state)

    # The main discrete event simulation loop - SIMPLE!
    while true
        # Get the next event
        timed_event = pop!(priority_queue)

        # Advance the time
        time = timed_event.time



        # Act on the event
        new_timed_events = process_event(time, state, params, timed_event.event) 

        # If the event was an end of simulation then stop
        if timed_event.event isa EndSimEvent
            break 
        end

        # The event may spawn 0 or more events which we put in the priority queue 
        for nte in new_timed_events
            push!(priority_queue,nte)
        end

        # Callback for each simulation event
        callback(time, state)
    end
    callback(time, state)
end;



# setting up and doing simulation ----------------------------



function create_scen1(λ::Float64)
    return NetworkParameters( L=3, 
    scv = 3.0, 
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
    if (s <: TrackAllJobs)
        return TrackAllJobs(Dict{Int64, Tuple{Float64, Int64}}(), Float64[], [Queue{Int64}() for _ in 1:(p.L)], 0)
    else 
        return TrackTotals(zeros(p.L), 0, [Queue{Int64}() for _ in 1:(p.L)], 0)
    end
end    

function create_init_event(p::NetworkParameters, s::State)
    dest = sample(collect(1:(p.L)), Weights(p.p_e))
    return TimedEvent(ExternalArrivalEvent(dest, new_job(s)), transit_time(params))
end



function do_sim(state_type; λ::Float64 = 1.0, max_time::Float64=10.0)

    params = create_scen1(λ + 0.0)
    state = create_init_state(state_type, params)
    init = create_init_event(params, state)
    if state_type <: TrackAllJobs
        # setup storage for ouput
        data = Vector{Float64}()
        
        record_data = function (time::Float64, state::TrackAllJobs)
            while !isempty(state.sojournPush)
                push!(data, pop!(state.sojournPush))
            end
        end
    else
        prev_time = [0.0]
        # first entry is running stat of average number of items in system
        # second entry is running stat of proportion of total jobs in transit
        data = zeros(2)

        record_data = function (time::Float64, state::TrackTotals)
            if time != 0 
                node_sum = sum(state.atNodes)
                data[1] = (data[1]*prev_time[1] + (state.transit + node_sum)*(time - prev_time[1])) / time

                if (node_sum + state.transit != 0)
                    # don't think this is quite right
                    data[2] = (data[2]*prev_time[1] + (state.transit / (node_sum + state.transit))*(time-prev_time[1]) ) / time
                else
                    # in this situation both node_sum and state.transit are 0. i.e the number of items in the system is zero. here the
                    # proportion is not defined so I think no update should be made
                end
            end
            prev_time[1] = time
        end
    end

    simulate(params, state, init, max_time = max_time, callback=record_data)

    return data
end



function plot_emp(data)
    f = ecdf(x)
    e = collect(min(x):0.01:max(x))
    plot(e, f(e), legend=false)
end


