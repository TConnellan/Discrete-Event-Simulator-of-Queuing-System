
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
# -----------

function new_job(state::State)::Int64
    return state.jobCount += 1
end

# -----------
function job_join_system end

function job_join_sys(job::Int64, node::Int64, time::Float64, state::TrackAllJobs)
    state.currentPosition[job] = (time, -1)
end   

function job_join_sys(job::Int64, node::Int64, time::Float64, state::TrackTotals)
    state.transit += 1
end

function job_leave_sys end

function job_leave_sys(job::Int64, node::Int64, time::Float64, state::TrackAllJobs)
    push!(state.sojournPush, time - arr_time(job, state))
    delete!(state.currentPosition, job)
end

function job_leave_sys(job::Int64, node::Int64, time::Float64, state::TrackTotals)
    # don't need to do anything in this, will already have left node and transit in other calls
end

# ----------------

function job_join_transit end

function job_join_transit(job::Int64, node::Int64, state::TrackAllJobs)
    state.currentPosition[job] = (arr_time(job, state), -1)
end   

function job_join_transit(job::Int64, node::Int64, state::TrackTotals)
    state.transit += 1
end

function job_leave_transit end

function job_leave_transit(job::Int64, state::TrackAllJobs)
    # do nothing
end

function job_leave_transit(job::Int64, state::TrackTotals)
    state.transit -= 1
end

#----------------

function job_join_node(job::Int64, node::Int64, state::TrackAllJobs)
    state.currentPosition[job] = (arr_time(job, state), node)
end

function job_join_node(job::Int64, node::Int64, state::TrackTotals)
    state.atNodes[node] +=1
end

function job_leave_node end

function job_leave_node(job::Int64, node::Int64, state::TrackAllJobs)
    # do nothing, need the new location so will be handled in the join function that is also called
end

function job_leave_node(job::Int64, node::Int64, state::TrackTotals)
    state.atNodes[node] -= 1
end


#---------------    

function arr_time(job::Int64, state::TrackAllJobs)::Float64
    if haskey(state.currentPosition, job)
        return state.currentPosition[job][1]
    else
        throw(error("Job is not currently in system"))
    end
end