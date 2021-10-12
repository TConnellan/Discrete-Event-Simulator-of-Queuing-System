using StatsBase

#same function for routing internal and external arrivals
#using multiple dispatch

#route external arrivals
function route(nodes::Vector{Int}, p_e::Vector{Float64})
    w = Weights(p_e)
    node = sample(nodes, w)
    return node
end

#test function above
nodes = collect(1:10)
p_e = [.1, 0, 0, 0, .2, 0, 0, 0, 0, .7]

for i=1:10
     println(route(nodes, p_e))
end


#function for project
function route(P::Array{Float64, 2}, from_node::Int)
    prob_from_node = Weights(P[from_node,:])
    nodes = collect(1:size(P)[2])
    return sample(nodes, prob_from_node)
end

#test function above
P = [0 1.0 0;
    0 0 1.0;
    0.5 0 0]

for i=1:3
    println("going from node $i to node ", route(P,i) )
end

#"""
#code below is obsolete, ignore. Can be deleted once the file is reviewed and finalised
#"""


    # m, n = size(P)
    # #create dictionary, store the probability of going from node m (row) to node n (col)
    # #for later work...make sure the dictionary is generated only once, don't repeat the code many times
    # d = Dict{Int64, Tuple{Vector{Int64}, Float64}}()
    # index = 1
    # for j=1:m, i=1:n
    #     #if i!=j #skip probability of job going from node to same node
    #         from_to_pair = [j, i] #j = row = 'from node', i = col = 'to node'
    #         #@show from_to_pair
    #         prob = P[j,i] #probability 
    #         push!(d, index => (from_to_pair, prob) )
    #         index +=1
    #     #end
    # end
    # sort(d)
    # @show d
    # return d[find_my_index(from_node, to_node)]

#     """
# assign unique integer to the entries of an r*c matrix,
# start from the left, on row 1, process all cols, then move to row 2, etc..
# """
# function find_my_index(r::Int, c::Int )
#     @assert m!=n #matrix must be square
#     return m*(r-1) + c
# end