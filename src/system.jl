
using StatsBase

# not sure if we want the whole system to be a struct, could just create a whole file which deals with executing the system
# may need to do that if having a mutable struct is costly
mutable struct System
    # list of stations
    nodes::Vector{Node}

    # list of jobs that have entered the system and where they are at what time, jobs could be not  arrived 
    # in the system, being served, in a buffer, travelling between nodes, left the system
    # will need this for the first mode

    # for second node just need to keep a count for each node and between nodes.

    
    # this keeps track of what needs to happen next in the system. The time of the system starts at zero
    # every time we need to figure out what a task will do next we calculate what it is, how long it will take
    # and then give that action the priority of the time + the systems time that a last action occured
    # any is in place of a function maybe?
    # 
    events::PriorityQueue{Vector{Any}, Float64}
    
    
    # routing matrix
    P::Matrix{Float64}
    # overflow matrix
    Q::Matrix{Float64}
    # external arrivals
    p::Vector{Float64}
    # current time in system
    t::Float64

    # travel rate same for moving between nodes after overflow and service. mean is 1/η
    # julia uses shape and scale parameters (as defined in the wiki article for the gamma distribution)
    # in order to satisfy mean/var = 3 this means that scale = 1/3 and shape = 1/(3η)
    
    travel_time::UnivariateDistribution

    # external entry rate, mean is 1/λ
    # by above reasoning, scale is 1/3 and shape is 1/(3η)
    ex_entry_time::UnivariateDistribution

    # mean service rate (1/μ_i) at each node 
    service_rates::Vector{UnivariateDistribution}

    # 
    leaving_prob_normal::Vector{Float64}
    
    leaving_prob_overflow::Vector{Float64}

    # need to think harder on how to construct it
    #System(P,Q) = new(Vector{Node}(), PriorityQueue{Vector{Any}, Float64}())
end


function System(nodes::Vector{Node},P::Matrix{Float64},Q::Matrix{Float64},p::Vector{Float64}, 
                            t::Uint64, η::Float64, λ::Float64, service_rates::Vector{Float64}) 
    return check_inputs(nodes, P, Q, p, t, η, λ, service_rates) ? new(nodes, P, Q, p, t, Gamma(1/3,1/(3*η)),Gamma(1/3,1/(3*λ)), [Gamma(1/3,1/(3*μ)) for μ in service_rates], [1-sum(P[i]...) for i in 1:length(nodes)], [1-sum(Q[i]...) for i in 1:length(nodes)]) : throw("Input dimensions incorrect")
end

function advance_system(sys::System)
    if (!isempty(sys.events))
        new_time = peek(sys.events)
        e = dequeue!(sys.events)
        fun = e[1]
        args = e[2:end]
        fun(args...)
        sys.time = new_time
    else
        println("system has ended")
        return false
    end
    return true
end

function enter_system!(sys::System, job::UInt64)
    dest = sample(sys.nodes,Weights(sys.p))
    # may need to incorporate travel time to the node?
    # if so then enqueue trying to enter the node into the priority queue
    
    # there may not actually be travel time when first entering the system, need to check, if this is the
    # case then can just call enter_node! here.
    time = sys.t + rand(sys.travel_time)
    enqueue!(sys.events, [enter_node!, sys, dest, job], time)
    # if no travel time we just do
    # enqueue!(dest.node.buffer, job)

    # find out when the next job will arrive and add that event to the queue
    enqueue!(sys.events, [enter_system!, sys, job + 1], sys.t + rand(ex_entry_time))
    # push next entry into the system into the priority queue
end




function check_system_inputs(nodes::Vector{Any}, P::Matrix{Float64}, 
                                Q::Matrix{Float64}, p::Vector{Float64}, 
                                η::Float64, λ::Float64, service_rates::Vector{Float64})
    p1,p2 = size(P)
    q1,q2 = size(Q)
    # check that matrices are square and their dimensions correspond to the amount of nodes

    # still need to check that transition matrices & vectors rows sum to less than 1, think
    # can do this by checking max eigenvalue
    if (p1 != p2 || q1 != q2 || length(nodes) != p1 || length(p) != p1 || p1 != length(service_rates)
                || η <= 0 || λ <= 0 || !isnothing(findfirst(<=(0), service_rates)))
        return false
    end
    return true
end
  
