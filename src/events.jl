using DataStructures
import Base: isless

abstract type Event end


# Captures an event and the time it takes place
struct TimedEvent
    event::Event
    time::Float64

    TimedEvent(event::Event, time::Float64) = new(event, time)
end

struct PlaceHolderEvent <: Event end

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
                                es_event::EndSimEvent, new_ev::Vector{TimedEvent})::Nothing
    #println("Ending simulation at time $time.")
    return nothing
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
                                ext_event::ExternalArrivalEvent, new_ev::Vector{TimedEvent})::Nothing
    # Since the first arrival is instantaneous the state will be immediately altered in join_node
    # before any callback function is called
    job_join_sys(ext_event.job, ext_event.node, time, state) #effectively join_transit but deals with storing initial time

    join_node(time, ext_event.job, ext_event.node, state, params, new_ev)

    t = time + ext_arr_time(params)
    dest = route_ext_arr(params.L_vec, params.p_e_w)
    push!(new_ev, TimedEvent(ExternalArrivalEvent(dest, new_job(state)), t))
    return nothing
end

struct JoinNodeEvent <: Event 
    # the destination of the job in transit
    node::Int64
    # the identifier of the job in transit
    job::Int64
end

function process_event(time::Float64, state::State, params::NetworkParameters, 
                        join_event::JoinNodeEvent, new_ev::Vector{TimedEvent})::Nothing
    join_node(time, join_event.job, join_event.node, state, params, new_ev)
    return nothing
end

struct ServiceCompleteEvent <: Event
    # the destination of the new arrival
    node::Int64
end

function process_event(time::Float64, state::State, params::NetworkParameters, 
                            sc_event::ServiceCompleteEvent, new_ev::Vector{TimedEvent})::Nothing
    done_service = get_served(sc_event.node, state)
    job_leave_node(done_service, sc_event.node, state)

    dest = route_int_trav(params.L_vec, params.P_w[sc_event.node])
    if is_leaving(dest)
        job_leave_sys(done_service, sc_event.node, time, state)
    else
        t = time + transit_time(params)
        push!(new_ev, TimedEvent(JoinNodeEvent(dest, done_service), t))
        job_join_transit(done_service, sc_event.node, state)
    end

    # if the buffer is not empty start serving a new job
    if jobs_at_node(sc_event.node, state) > 0
        t = time + service_time(params, sc_event.node)
        push!(new_ev, TimedEvent(ServiceCompleteEvent(sc_event.node), t))
        job_begin_service(get_served(sc_event.node, state), state)
    end
    return nothing
end


function join_node(time::Float64, job::Int64, node::Int64, state::State, 
                                params::NetworkParameters, new_ev::Vector{TimedEvent})::Nothing
    # new_ev = Vector{TimedEvent}()

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
        dest = route_int_trav(params.L_vec, params.Q_w[node])
        if (is_leaving(dest)) 
            # leave system, no new event, just need to deal with tracking
            job_leave_transit(job, state)
            job_leave_sys(job, node, time, state)
        else
            push!(new_ev, TimedEvent(JoinNodeEvent(dest, job), t))
            # don't need any update
        end
    end
    return nothing
end


function add_events(event_list::Vector{TimedEvent}, event::TimedEvent)::Nothing
    if isnothing(event_list[1])
        event_list[1] = event
    elseif isnothing(event_list[2])
        event_list[2] = event
    else
        throw("more than two new events generated")
    end
    return nothing
end

function has_events(evl::Vector{TimedEvent})::Bool
    #println("$(!isnothing(evl[1]))              $(!isnothing(evl[2]))")
    return !(evl[1].event <: PlaceHolderEvent) || !(evl[2].event <: PlaceHolderEvent)
end

function get_events(evl::Vector{TimedEvent})::TimedEvent
    if !(evl[1].event <: PlaceHolderEvent)
        temp = evl[1]
        evl[1] = TimedEvent(PlaceHolderEvent(), 0) 
        return temp
    elseif !(evl[2].Event <: PlaceHolderEvent)
        temp = evl[2]
        evl[2] = TimedEvent(PlaceHolderEvent(), 0) 
        return temp
    else
        throw("called get_events with no events in vector")
    end
end