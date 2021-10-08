using DataStructures
import Base: isless

abstract type Event end


# Captures an event and the time it takes place
struct TimedEvent
    event::Event
    job::Uint64
    node::Uint64
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

function process_event(time::Float64, job::Uint64, node::Uint64, state::State, es_event::EndSimEvent)
    println("Ending simulation at time $time.")
    return []
end

struct ExternalArrivalEvent <: Event end

function process_event(time::Float64, job::Uint64, node::Uint64, state::State, e::ExternalArrivalEvent)
    #update state here
    update_state(job, node, state, e)

    # implement functionality here
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