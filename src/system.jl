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
                    callback = (time, state, data, meta) -> nothing)

    # The event queue
    priority_queue = BinaryMinHeap{TimedEvent}()

    data, meta = initialise_data(init_state)


    # Put the standard events in the queue
    push!(priority_queue, init_timed_event)
    push!(priority_queue, TimedEvent(EndSimEvent(), max_time))


    # initilize the state
    state = deepcopy(init_state)
    time = 0.0

    # Callback at simulation start
    callback(time, state, data, meta)

    new_events = Vector{TimedEvent}()

    # The main discrete event simulation loop - SIMPLE!
    while true
        # Get the next event
        timed_event = pop!(priority_queue)

        # Advance the time
        time = timed_event.time



        # Act on the event
        #new_timed_events = 
        process_event(time, state, params, timed_event.event, new_events) 

        # If the event was an end of simulation then stop
        if timed_event.event isa EndSimEvent
            break 
        end
        # The event may spawn 0 or more events which we put in the priority queue 
        while (!isempty(new_events))
            push!(priority_queue, pop!(new_events))
        end

        # Callback for each simulation event
        callback(time, state, data, meta)
    end
    #callback at simulation end
    callback(time, state, data, meta)
    return data
end;

function initialise_data(s::TrackAllJobs)::Tuple{Vector{Float64}, Vector{Float64}}
    out = Vector{Float64}(), Float64[]
    return out
end

function initialise_data(s::TrackTotals)::Tuple{Vector{Float64}, Vector{Float64}}
    return zeros(2), zeros(4)
end

function record_data(time::Float64, state::TrackAllJobs, data::Vector{Float64}, meta::Vector{Float64})
    while !isempty(state.sojournTimes)
        push!(data, pop!(state.sojournTimes))
    end
end


#meta = [prev_time, prev_count, prev_prop, prop_time]
function record_data(time::Float64, state::TrackTotals, data::Vector{Float64}, meta::Vector{Float64})
    node_sum = sum(state.atNodes) # the total number of items either being served or in a buffer at the nodes
    if time != 0
        
        #data[1] = (data[1]*meta[1] + (state.transit + node_sum)*(time - meta[1])) / time
        # I believe the below gives the right weighting, same with prop
        data[1] = (data[1]*meta[1] + meta[2]*(time - meta[1])) / time
        

        
        #if (node_sum + state.transit != 0)
        if (meta[2] != 0)
            #data[2] = (data[2]*meta[1] + (state.transit / (node_sum + state.transit))*(time-meta[1]) ) / time
            #data[2] = (data[2]*meta[1] + meta[3]*(time-meta[1])) / time
            data[2] = (data[2]*meta[4] + meta[3]*(time-meta[1])) / (meta[4] + time - meta[1]) #best version?
            meta[4] += (time - meta[1])
        end
    end
    meta[1] = time
    meta[2] = state.transit + node_sum
    meta[3] = state.transit / (node_sum + state.transit)
    return
end

# setting up and doing simulation ----------------------------


function create_init_state(s, p::NetworkParameters)
    if (s <: TrackAllJobs)
        return TrackAllJobs(Dict{Int64, Tuple{Float64, Int64}}(), Float64[], [Queue{Int64}() for _ in 1:p.L], 0)
    else 
        return TrackTotals(zeros(p.L), 0, 0)
    end
end    

function create_init_event(p::NetworkParameters, s::State)
    dest = route_ext_arr(p.L_vec, p.p_e_w)
    return TimedEvent(ExternalArrivalEvent(dest, new_job(s)), transit_time(p))
end


# deprecated, current best function is run_sim()
function do_sim(state_type; λ::Float64 = 1.0, max_time::Float64=10.0)

    params = create_scen1(λ + 0.0)
    state = create_init_state(state_type, params)
    init = create_init_event(params, state)
    if state_type <: TrackAllJobs
        # setup storage for ouput
        data = Vector{Float64}()
        
        record_data = function (time::Float64, state::TrackAllJobs, c::Vector{Float64},y::Vector{Float64})
            while !isempty(state.sojournTimes)
                #println("$(state.sojournTimes)")
                push!(data, pop!(state.sojournTimes))
            end
        end
    else
        prev_time = [0.0]
        prev_count = [0.0]
        prev_prop = [0.0]
        # the total cumulative up until this point in which the proportion was defined
        prop_time = [0.0]
        # first entry is running stat of average number of items in system
        # second entry is running stat of proportion of total jobs in transit
        data = zeros(2)
        #data2 = Vector{Vector{Float64}}()

        record_data = function (time::Float64, state::TrackTotals, c::Vector{Float64},y::Vector{Float64})
            #push!(data2, [[time, state.transit] ; state.atNodes])
            #return
            node_sum = sum(state.atNodes) # the total number of items either being served or in a buffer at the nodes
            if time != 0
                
                #data[1] = (data[1]*prev_time[1] + (state.transit + node_sum)*(time - prev_time[1])) / time
                
                
                # I believe the below gives the right weighting, same with prop
                data[1] = (data[1]*prev_time[1] + prev_count[1]*(time - prev_time[1])) / time

                


                #prev_mean = data[1]
                # we extract from the previous mean the total number of items observed up until this currentPosition
                #prev_total = prev_mean*prev_time[1]
                # get the new count of items by adding the weighted (according to the time interval) number of items currently in the system
                #new_total = prev_total + (state.transit + node_sum)*(time-prev_time)
                #new_avg = new_total / time
        

                #this is messed up, don't know which one it should be
                #if (node_sum + state.transit != 0)
                if (prev_count[1] != 0)
                    #this was the first way, doesn't weight using the right time periods
                    #data[2] = (data[2]*prev_time[1] + (state.transit / (node_sum + state.transit))*(time-prev_time[1]) ) / time
                    #this was the second way, does weight using the right time periods but
                    #uses the full time in the denominator. There are times when the proportion is undefined
                    #i.e no items in system so we do not want consider these time periods
                    #data[2] = (data[2]*prev_time[1] + prev_prop[1]*(time-prev_time[1])) / time 

                    # the third and hopefully final way, fixes the previous problem
                    data[2] = (data[2]*prop_time[1] + prev_prop[1]*(time-prev_time[1])) / (prop_time[1] + time - prev_time[1])
                    prop_time[1] += (time - prev_time[1])
                else
                    #println("rare")
                end
                
                
            end
            prev_time[1] = time
            prev_count[1] = state.transit + node_sum
            
            prev_prop[1] = state.transit / (node_sum + state.transit)
            
        end
    end

    simulate(params, state, init, max_time = max_time, callback=record_data)
    print("-")
    #return data2
    return data
end


function plot_mean_items(Λ::Vector{Float64}, means::Vector{Float64})
    @assert length(Λ) == length(means)
    plot(Λ, means)
end



function plot_emp(Λ::Vector{Float64}, data::Vector{Vector{Float64}}; title = "emp dist plot", xscale=:identity, xlims=[:auto, :auto], legend=:bottomright, xlabel_log="")
    m = maximum([maximum(d) for d in data])
    f = ecdf(data[1])
    #e = collect(0:0.01:(maximum(data[1])+0.01))
    e = collect(0:0.01:(m+0.01))
    k = plot(e, f(e), labels="$(Λ[1])", legend=legend, legendtitle="λ", title=title, xscale=xscale, xlims=xlims,
                    xlabel="Sojourn time$(xlabel_log)", ylabel="Empirical Distribution")
    #k = plot(stich_steps(e, f(e))..., labels="$(Λ[1])", legend=:bottomright, legendtitle="λ", title=title)

    for i in 2:length(data)
        f = ecdf(data[i])
        #e = collect(0:0.01:(maximum(data[1])+0.01))
        plot!(e, f(e), labels="$(Λ[i])")
    end
    return k
end




function stich_steps(epochs, values)
    n = length(epochs)
    new_epochs  = [epochs[1]]
    new_values = [values[1]]
    for i in 2:n
        push!(new_epochs, epochs[i])
        push!(new_values, values[i-1])
        push!(new_epochs, epochs[i])
        push!(new_values, values[i])
    end
    return (new_epochs, new_values)
end

function run_sim(state_type, param_func; λ::Float64 = 1.0, max_time::Float64=10.0)

    params = param_func(λ)
    state = create_init_state(state_type, params)
    init = create_init_event(params, state)
    return simulate(params, state, init, max_time = max_time, callback=record_data)
end
