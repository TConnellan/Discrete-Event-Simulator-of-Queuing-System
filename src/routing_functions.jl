using StatsBase

#same function for routing internal and external arrivals
#using multiple dispatch

#route external arrivals
function route_ext_arr(nodes::Vector{Int}, p_e::Vector{Float64})::Int64
    @assert length(nodes) == length(p_e)
    w = Weights(p_e)
    node = sample(nodes, w)
    return node
end

#=
#test function above
nodes = collect(1:10)
p_e = [.1, 0, 0, 0, .2, 0, 0, 0, 0, .7]

for i=1:10
     println(route_ext_arr(nodes, p_e))
end
=#

#function for project
function route_int_trav(node_list::Vector{Int64}, from_node::Int, P::Array{Float64, 2})::Int64
    n, m = size(P)
    @assert n == m
    @assert 1 <= from_node <= n

    # need to account for possibility that the job will leave system
    probs = P[from_node,:]
    prob_leave = 1 - sum(probs)
    prob_from_node = Weights([probs ; prob_leave])


    # let -1 denote leaving the system
    nodes = [node_list ; -1]
    return sample(nodes, prob_from_node)
end

function is_leaving(dest::Int64)::Bool
    return dest == -1 ? true : false
end