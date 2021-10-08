


# this file is old, not used in implementation


























# may have same problem here with mutability
mutable struct Node
    #queue::PriorityQueue{Int, Float64}
    # maybe just a normal queue actually, store the service time only for the job currently being served
    # and calculate a new one for each in the queue
    id::UInt64
    buffer::Queue{UInt64}
    capacity::UInt64
    serving::UInt64

    Node(id::Uint64, capacity::Uint64) = new(id, Queue{UInt64}(), capacity, nothing)
    Node(id::UInt64, buffer::Queue{UInt64}, capacity::UInt64, serving::Uint64) = check_node(id, buffer) ? new() : throw("node construction error")
end


function enter_node!(sys::System, node::Node, job::UInt64)
    if isnothing(node.serving)
        node.serving = job
        enqueue!(sys.events, [leave_node!, sys, node], sys.t + rand(sys.travel_time))
    else if length(node.buffer) < node.capacity
        enqueue!(node.buffer, job)
    else
        # we are overflowing
        dest = sample([sys.nodes ; -1], Weights([sys.Q[node.id] ; leaving_prob_overflow]))
        if dest == -1
            # leave system, need to update whatever tracking where doing, otherwise, dont do anything
        else
            enqueue(sys.events, [enter_node!, sys, dest, job], sys.t + rand(sys.travel_time))
        end
    end
end

# only leave the node once its been served so don't need to specify which job is leaving
function leave_node!(sys::System, node::Node)
    # get the new destination
    dest = sample([sysnodes ; -1], Weights([sys.P[node.id] ; sys.leaving_prob_norm[i]]))
    if dest == -1
        if isempty(node.buffer)
            node.serving = nothing
        else
            # get new job to serve
            node.serving = dequeue!(node.buffer)
            # schedule when the new job should leave
            enqueue!(sys.events, [leave_node!, sys, node], sys.t + rand(sys.service_rates[node.id]))
        end
    else
        # schedule the arrival at the next node
        enqueue!(sys.events, [enter_node!, sys, dest, node.serving], sys.t + rand(sys.travel_time))
        # get new job to serv at this node
        node.serving = dequeue!(node.buffer)
        # schedule when the new job will leave
        enqueue!(sys.events, [leave_node!, sys, node], sys.t + rand(sys.service_rates[node.id]))
    end
end

function check_node(id::Int, buffer::Queue{Int})
    b = deepcopy(buffer)
    d = Dict()
    while !isempty(d)
        e = dequeue!(b)
        if(haskey(d, e))
            # nodes with same id
            return false
        end
    end
    return true
end