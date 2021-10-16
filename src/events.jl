using DataStructures
import Base: isless

abstract type Event end


# Captures an event and the time it takes place
struct TimedEvent
    event::Event
    time::Float64

    TimedEvent(event::Event, time::Float64) = new(event, time)
end

# Comparison of two timed events - this will allow us to use them in a heap/priority-queue
isless(te1::TimedEvent, te2::TimedEvent)::Bool = te1.time < te2.time

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

function process_event(time::Float64, state::State, params::NetworkParameters, 
                                es_event::EndSimEvent)::Vector{TimedEvent}
    #println("Ending simulation at time $time.")
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

function process_event(time::Float64, state::State, params::NetworkParameters, 
                                ext_event::ExternalArrivalEvent)::Vector{TimedEvent}
    # Since the first arrival is instantaneous the state will be immediately altered in join_node
    # before any callback function is called
    job_join_sys(ext_event.job, ext_event.node, time, state) #effectively join_transit but deals with storing initial time

    new_events = join_node(time, ext_event.job, ext_event.node, state, params)

    t = time + ext_arr_time(params)
    dest = route_ext_arr(collect(1:params.L), params.p_e)
    push!(new_events, TimedEvent(ExternalArrivalEvent(dest, new_job(state)), t))
    return new_events
end

struct JoinNodeEvent <: Event 
    # the destination of the job in transit
    node::Int64
    # the identifier of the job in transit
    job::Int64
end

function process_event(time::Float64, state::State, params::NetworkParameters, 
                        join_event::JoinNodeEvent)::Vector{TimedEvent}
    return join_node(time, join_event.job, join_event.node, state, params)
end

struct ServiceCompleteEvent <: Event
    # the destination of the new arrival
    node::Int64

    # the job being completed will always be the job at the front of the queue at the node
    # this could change if we decide to store the job being served separate from the buffer
end

function process_event(time::Float64, state::State, params::NetworkParameters, 
                            sc_event::ServiceCompleteEvent)::Vector{TimedEvent}
    out = Vector{TimedEvent}()
    done_service = get_served(sc_event.node, state)
    job_leave_node(done_service, sc_event.node, state)

    dest = route_int_trav(sc_event.node, params.P)
    if dest != -1
        t = time + transit_time(params)
        push!(out, TimedEvent(JoinNodeEvent(dest, done_service), t))
        job_join_transit(done_service, sc_event.node, state)
    else
        job_leave_sys(done_service, sc_event.node, time, state)
    end

    # if the buffer is not empty start serving a new job
    if jobs_at_node(sc_event.node, state) > 0
        t = time + service_time(params, sc_event.node)
        push!(out, TimedEvent(ServiceCompleteEvent(sc_event.node), t))
    end
    return out
end


function join_node(time::Float64, job::Int64, node::Int64, state::State, 
                                params::NetworkParameters)::Vector{TimedEvent}
    new_ev = Vector{TimedEvent}()

    if (check_capacity(node, params, state))
        job_leave_transit(job, state)
        job_join_node(job, node, state)

        # job is first in buffer and thus being served
        if jobs_at_node(node, state) == 1
            t= time + service_time(params, node)
            push!(new_ev, TimedEvent(ServiceCompleteEvent(node), t))
        end
    else
        # overflow
        t = time + transit_time(params)
        dest = route_int_trav(node, params.Q)
        if (dest == -1) 
            # leave system, no new event, just need to deal with tracking
            job_leave_transit(job, state)
            job_leave_sys(job, node, time, state)
        else
            push!(new_ev, TimedEvent(JoinNodeEvent(dest, job), t))
            # don't need any update
        end
    end
    return new_ev
end
