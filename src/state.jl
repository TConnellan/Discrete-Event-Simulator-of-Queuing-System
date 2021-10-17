
using DataStructures

abstract type State end

# which state we use will determine what we track


# track all jobs
mutable struct TrackAllJobs <: State
    # maps each job that is currently in the system to [entry_time, current_location, being_served]. current_location = -1 means in transit.
    # being_served is either 1 for true or 0 for false.
    # when a job leaves we remove it from the dictionary
    currentPosition::Dict{Int64, Vector{Float64}}
    # contains the sojourn times of all the jobs that have left the system
    # is emptied by the callback function
    sojournTimes::Vector{Float64}

    # may not need currentPosition, just have Dict or arr with entry times
    # and a collection of jobs in transit
    # maybe storing currentPosition will just be faster who knows

    buffers::Vector{Queue{Int64}}
    jobCount::Int64
end

#track only total jobs in each location
mutable struct TrackTotals <: State
    atNodes::Vector{Int64}
    transit::Int64

    #buffers::Vector{Queue{Int64}}
    jobCount::Int64
end
# -----------

"""
Get a new unique identifier for a job
"""
function new_job(state::TrackAllJobs)::Int64
    return state.jobCount + 1
end

"""
Get a new unique identifier for a job
"""
function new_job(state::TrackTotals)::Int64
    return state.jobCount + 1
end

# -----------
function job_join_system end

"""
Update the system to reflect a job joining it
"""
function job_join_sys(job::Int64, node::Int64, time::Float64, state::TrackAllJobs)::Int64
    state.currentPosition[job] = [time, -1, 0]
    state.jobCount += 1
end

"""
Update the system to reflect a job joining it
"""
function job_join_sys(job::Int64, node::Int64, time::Float64, state::TrackTotals)::Int64
    state.transit += 1
    state.jobCount += 1
end

function job_leave_sys end

function job_leave_sys(job::Int64, node::Int64, time::Float64, state::TrackAllJobs)::Nothing
    push!(state.sojournTimes, time - arr_time(job, state))
    delete!(state.currentPosition, job)
    return nothing
end

function job_leave_sys(job::Int64, node::Int64, time::Float64, state::TrackTotals)::Nothing
    # don't need to do anything in this, will already have left node and transit in other calls
end

# ----------------

function job_join_transit end

function job_join_transit(job::Int64, node::Int64, state::TrackAllJobs)
    state.currentPosition[job][2] = -1
end   

function job_join_transit(job::Int64, node::Int64, state::TrackTotals)::Int64
    return state.transit += 1
end

function job_leave_transit end

function job_leave_transit(job::Int64, state::TrackAllJobs)
    # do nothing
    # unless I implement a collection storing jobs in transit somewhere
end

function job_leave_transit(job::Int64, state::TrackTotals)
    @assert state.transit >= 1
    state.transit -= 1
end

#----------------

function job_join_node(job::Int64, node::Int64, state::TrackAllJobs)
    state.currentPosition[job][2] = node
    enqueue!(state.buffers[node], job)
end

function job_join_node(job::Int64, node::Int64, state::TrackTotals)::Int64
    return state.atNodes[node] +=1
end

function job_leave_node end

function job_leave_node(job::Int64, node::Int64, state::TrackAllJobs)::Int64
    # job must have completed service in order to have left the node

    # no longer being served
    state.currentPosition[job][3] = 0
    #leave the buffer
    return dequeue!(state.buffers[node])
end

function job_leave_node(job::Int64, node::Int64, state::TrackTotals)::Int64
    @assert state.atNodes[node] >= 1
    state.atNodes[node] -= 1
    return 1
end


#---------------    

function job_begin_service(job::Int64, state::TrackAllJobs)
    state.currentPosition[job][3] = 1
    return
end

function job_begin_service(job::Int64, state::TrackTotals)
    # do nothing
    return
end

#--------------
function arr_time(job::Int64, state::TrackAllJobs)::Float64
    if haskey(state.currentPosition, job)
        return state.currentPosition[job][1]
    else
        throw(error("Job $job is not currently in system"))
    end
end




function get_served(node::Int64, state::TrackAllJobs)::Int64
    return first(state.buffers[node])
end

function get_served(node::Int64, state::TrackTotals)::Int64
    @assert length(state.atNodes[node]) > 0
    return 1
end





function check_capacity(node::Int64, params::NetworkParameters, state::TrackAllJobs)::Bool
    # first element in buffer is the one being served hence max elements in buffer is K + 1
    return params.K[node] == -1 || length(state.buffers[node]) < params.K[node] + 1
end

function check_capacity(node::Int64, params::NetworkParameters, state::TrackTotals)::Bool
    return params.K[node] == -1 || state.atNodes[node] < params.K[node] + 1
end


# includes being served
function jobs_at_node(node::Int64, state::TrackAllJobs)::Int64
    return length(state.buffers[node])
end

function jobs_at_node(node::Int64, state::TrackTotals)::Int64
    return state.atNodes[node]
end