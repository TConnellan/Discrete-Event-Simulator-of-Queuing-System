
using DataStructures

abstract type State end

# which state we use will determine what we track


# track all jobs
mutable struct TrackAllJobs <: State
    # -2 means left system, -1 means in transit
    # maybe when a job leaves we remove it from the dictionary
    currentPosition::Dict{Int64, Tuple{Float64, Int64}}
    sojournPush::Vector{Float64}

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