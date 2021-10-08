using DataStructures
import Base: isless

abstract type Event end


# Captures an event and the time it takes place
struct TimedEvent
    event::Event
    job::UInt64
    node::UInt64
    time::Float64
end

TimedEvent(event::Event, time::Float64) = new(event, nothing, nothing, time)
TimedEvent(event::Event, job::UInt64, time::Float64) = new(event, job, nothing, time)
# if we need the constructor for a node but no job then implement it but I don't think we need it

# Comparison of two timed events - this will allow us to use them in a heap/priority-queue
isless(te1::TimedEvent, te2::TimedEvent) = te1.time < te2.time

"""
    new_timed_events = process_event(time, state, event)

Generate an array of 0 or more new `TimedEvent`s based on the current `event` and `state`.
"""
function process_event end # This defines a function with zero methods (to be added later)

# Generic events that we can always use

"""
    EndSimEvent()

Return an event that ends the simulation.
"""
struct EndSimEvent <: Event end

function process_event(time::Float64, job::UInt64, node::UInt64, state::State, es_event::EndSimEvent)
    println("Ending simulation at time $time.")
    return []
end

"""
A job with unique number arriving at node at time t
"""
struct ExternalArrivalEvent <: Event end

function process_event(time::Float64, job::UInt64, node::UInt64, state::State, 
                        params::NetworkParameters, ext_event::ExternalArrivalEvent)
    
    if (state isa TrackTotals)
        # will be removed in join_node, makes implementing join_node easier
        state.transit += 1
    end
    new_events = Vector{TimedEvent}()

    push!(new_events, join_node(time, job, node, state, params))


    t = time + Gamma(1/3, 3/params.λ)
    dest = sample(collect(1:params.L), Weights(params.p_e))
    # the state.jobCount += 1 changes the state and returns the changed value
    push!(new_events, TimedEvent(ExternalArrivalEvent(), state.JobCount += 1, dest, t))

    return new_events
end

struct JoinNodeEvent <: Event end

function process_event(time::Float64, job::UInt64, node::UInt64, 
                        state::State, params::NetworkParameters, 
                        join_event::JoinNodeEvent)
    
    new_events = Vector{TimedEvent}()
    push!(new_events, join_node(time, job, node, state, params))

    return new_events
end


struct ServiceCompleteEvent <: Event end

function process_event(time::Float64, job::UInt64, node::UInt64, 
                        state::State, params::NetworkParameters, 
                        sc_event::ServiceCompleteEvent)
    out = Vector{TimedEvent}()
    dest = sample([collect(1:params.L) ; -1], Weights([params.P[node] ; 1-sum(params.P[node])]))
    if dest != -1
        t = time + Gamma(1/3, 3/params.η)
        push!(out, TimedEvent(JoinNodeEvent(), job, dest, t))
    end
    if (state isa TrackAllJobs)
        state.currentPosition[job] = (dest == -1) ? -2 : -1
    else
        state.atNodes[node] -= 1
        state.transit += (dest == -1) ? 0 : -1
    end

    return out
end



function join_node(time::Float64, job::UInt64, node::UInt64, state::State, params::NetworkParameters)
    out = Vector{TimedEvent}
    # first element in buffer is being served so K + 1
    if (params.K[node] == -1 || length(state.buffers[node]) < params.K[node] + 1)
        push!(state.buffers[node], job)

        # job is first in buffer and thus being served
        if length(state.buffers[node] == 1)
            t = time + Gamma(1/3,3/params.μ_vector[node])
            push!(out, TimedEvent(ServiceCompleteEvent(), job, node, t))
        end
        if (state isa TrackAllJobs)
            state.currentPosition[job] = node
        else
            state.atNodes[node] +=1
            state.transit -= 1
        end
    else
        # overflow
        t = time + Gamma(1/3, 3/params.η)
        dest = sample([collect(1:params.L) ; -1], Weights([params.Q[node] ; 1-sum(params.Q[node])]))
        if (dest == -1) 
            # leave system 

            # need to deal with tracking
            if (state isa TrackAllJobs)
                state.currentPosition[job] = -2
            else
                state.transit -= 1
            end
        else
            push!(out, TimedEvent(JoinNodeEvent(), job, dest, t))
            if (state isa TrackAllJobs)
                state.currentPosition[job] = -1
            else
                state.transit += 1
            end
        end
    end

    return out
end













#=
"""
    LogStateEvent()

Return an event that prints a log of the current simulation state.
"""
struct LogStateEvent <: Event end

function process_event(time::Float64, state::State, ls_event::LogStateEvent)
    println("Logging state at time $time.")
    println(state)
    return []
end
=#