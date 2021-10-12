
using DataStructures

abstract type State end

# which state we use will determine what we track


# track all jobs
mutable struct TrackAllJobs <: State
    # -2 means left system, -1 means in transit
    # maybe when a job leaves we remove it from the dictionary
    currentPosition::Dict{Int64, Int64}


    buffers::Vector{Queue{Int64}}
    jobCount::Int64
end

#track only total jobs in each location
mutable struct TrackTotals <: State
    atNodes::Vector{Int64}
    transit::Int64



    buffers::Vector{Queue{Int64}}
    jobCount::Int64
end


function increment_node(job)

end












#define functions to update each state given a certain event
# this was hard coded in the appropriate areas
# function update_state end



#function update_state(job::int64, node::int64, state::State, event::EndSimEvent) etc