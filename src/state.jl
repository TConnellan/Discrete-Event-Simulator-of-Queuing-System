
using DataStructures

abstract type State end

# which state we use will determine what we track


# track all jobs
mutable struct TrackAllJobs <: State
    # -2 means left system, -1 means in transit
    # maybe when a job leaves we remove it from the dictionary
    currentPosition::Dict{UInt64, Int64}


    buffers::Vector{Queue{UInt64}}
    jobCount::UInt64
end

#track only total jobs in each location
mutable struct TrackTotals <: State
    atNodes::Vector{UInt64}
    transit::UInt64



    buffers::Vector{Queue{UInt64}}
    jobCount::UInt64
end

#define functions to update each state given a certain event
# this was hard coded in the appropriate areas
# function update_state end



#function update_state(job::Uint64, node::Uint64, state::State, event::EndSimEvent) etc