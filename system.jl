
# not sure if we want the whole system to be a struct, could just create a whole file which deals with executing the system
# may need to do that if having a mutable struct is costly
mutable struct System<N>
    # list of stations
    # need to associate with each station a buffer, which takes the form of a (not necessarily priority) queue 
    nodes::Vector{N}
    
    
    
    
    # routing matrix
    P::Matrix{Float64}
    # overflow matrix
    Q::Matrix{Float64}
    # external arrivals
    p::Vector{Float64}
    
    System(nodes::Vector{N},P::Matrix{Float64},Q::Matrix{Float64},p::Vector{Float64}) = check_inputs(nodes, P, Q, p) ? new() : throw("Input dimensions incorrect")
end

function check_system_inputs(nodes::Vector{Any}, P::Matrix{Float64}, Q::Matrix{Float64}, p::Vector{Float64})
    p1,p2 = size(P)
    q1,q2 = size(Q)
    # check that matrices are square and their dimensions correspond to the amount of nodes
    if (p1 != p2 || q1 != q2 || length(nodes) != p1 || length(p) != p1)
        return false
    end
    return true
end
  
