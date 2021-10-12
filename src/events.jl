using DataStructures
import Base: isless

abstract type Event end


# Captures an event and the time it takes place
struct TimedEvent
    event::Event
    time::Float64

    TimedEvent(event::Event, time::Float64) = new(event, time)
end

#TimedEvent(event::Event, time::Float64) = TimedEvent(event, 1, 1, time)
#TimedEvent(event::Event, job::64, time::Float64) = TimedEvent(event, job, 1, time)
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

function process_event(time::Float64, state::State, params::NetworkParameters, es_event::EndSimEvent)
    println("Ending simulation at time $time.")
    return []
end

"""
A job with unique number arriving at node at time t
"""
struct ExternalArrivalEvent <: Event 

    # the destination of the new arrival
    node::Int64

    # the identifier of the new arrival
    job::Int64
end

function process_event(time::Float64, state::State, 
                        params::NetworkParameters, ext_event::ExternalArrivalEvent)
    
    if (state isa TrackTotals)
        # will be removed in join_node, makes implementing join_node easier
        state.transit += 1
    end

    new_events = join_node(time, ext_event.job, ext_event.node, state, params)
 
    
    t = time + rand(Gamma(1/3, 3/params.λ))
    dest = sample(collect(1:params.L), Weights(params.p_e))
    # the "state.jobCount += 1" changes the state and returns the changed value, all in one line
    push!(new_events, TimedEvent(ExternalArrivalEvent(dest, state.jobCount += 1), t))

    return new_events
end

struct JoinNodeEvent <: Event 
    # the destination of the job in transit
    node::Int64

    # the identifier of the job in transit
    job::Int64
end

function process_event(time::Float64, state::State, params::NetworkParameters, 
                        join_event::JoinNodeEvent)
    
    #new_events = Vector{TimedEvent}()
    #push!(new_events, join_node(time, join_event.job, join_event.node, state, params))

    return join_node(time, join_event.job, join_event.node, state, params)
end

struct ServiceCompleteEvent <: Event
    # the destination of the new arrival
    node::Int64

    # the job being completed will always be the job at the front of the queue at the node
    # this could change if we decide to store the job being served separate from the buffer
end

function process_event(time::Float64, state::State, params::NetworkParameters, sc_event::ServiceCompleteEvent)

    done_service = dequeue!(state.buffers[sc_event.node])

    out = Vector{TimedEvent}()
    dest = sample([collect(1:params.L) ; -1], Weights([params.P[sc_event.node] ; 1-sum(params.P[sc_event.node])]))
    if dest != -1
        t = time + rand(Gamma(1/3, 3/params.η))
        push!(out, TimedEvent(JoinNodeEvent(dest, done_service), t))
    end
    if (state isa TrackAllJobs)
        if dest == -1
            # remove entry from dictionary, saves space compared to setting value to -2
            delete!(state.currentPosition, done_service)
        else
            state.currentPosition[done_service] = -1
        end
        #state.currentPosition[done_service] = (dest == -1) ? -2 : -1
    else
        state.atNodes[sc_event.node] -= 1
        state.transit += (dest == -1) ? 0 : 1
    end
    
    # if the buffer is not empty start serving a new job
    if (!isempty(state.buffers[sc_event.node]))
        t = time + rand(Gamma(1/3, 3/params.μ_vector[sc_event.node]))
        push!(out, TimedEvent(ServiceCompleteEvent(sc_event.node), t))
        #if we need to distinguish between a job being served and in a buffer then need to update state here
    end

    return out
end

function join_node(time::Float64, job::Int64, node::Int64, state::State, params::NetworkParameters)
    out = Vector{TimedEvent}()

    # first element in buffer is the one being served hence max elements in buffer is K + 1
    if (params.K[node] == -1 || length(state.buffers[node]) < params.K[node] + 1)
        enqueue!(state.buffers[node], job)

        # job is first in buffer and thus being served
        if length(state.buffers[node]) == 1
            t = time + rand(Gamma(1/3,3/params.μ_vector[node]))
            push!(out, TimedEvent(ServiceCompleteEvent(node), t))
        end
        if (state isa TrackAllJobs)
            state.currentPosition[job] = node
        else
            state.atNodes[node] +=1
            state.transit -= 1
        end
    else
        # overflow
        t = time + rand(Gamma(1/3, 3/params.η))
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
            push!(out, TimedEvent(JoinNodeEvent(dest, job), t))
            if (state isa TrackAllJobs)
                state.currentPosition[job] = -1
            else
                # don't need to update in this situation, if this is an external arrival then its handled in its process_event() function
                # if its an internal arrival then it must have already been in transit so we don't need to change state.transit at all
                #state.transit += 1
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