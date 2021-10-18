using Parameters #You need to install the Parameters.jl package: https://github.com/mauro3/Parameters.jl 
using LinearAlgebra 
using DataStructures
using Distributions

#The @with_kw macro comes from the Parameters package
@with_kw mutable struct NetworkParameters
    #L::Int
    L::Int64
    scv::Float64 #This is constant for all scenarios at 3.0
    λ::Float64 #This is undefined for the scenarios since it is varied
    η::Float64 #This is assumed constant for all scenarios at 4.0
    μ_vector::Vector{Float64} #service rates
    P::Matrix{Float64} #routing matrix
    Q::Matrix{Float64} #overflow matrix
    p_e::Vector{Float64} #external arrival distribution
    K::Vector{Int64} #-1 means infinity 

    L_vec::Vector{Int64}
    P_w::Vector{Weights{Float64, Float64, Vector{Float64}}}
    Q_w::Vector{Weights{Float64, Float64, Vector{Float64}}}
    p_e_w::Weights{Float64, Float64, Vector{Float64}}
    #=
    function NetworkParameters(L::Int64,
                                scv::Float64,
                                λ::Float64,
                                η::Float64,
                                μ_vector::Vector{Float64},
                                P::Matrix{Float64},
                                Q::Matrix{Float64},
                                p_e::Vector{Float64},
                                K::Vector{Int64},
                                L_vec::Vector{Int64},
                                P_w::Weights{Float64, Float64, Vector{Float64}},
                                Q_w::Weights{Float64, Float64, Vector{Float64}},
                                p_e_w::Weights{Float64, Float64, Vector{Float64}})
        return new(L, scv, λ, η, μ_vector, P, Q, p_e, K, L_vec, P_w, Q_w, p_e_w)
    end=#
end

function NetworkParameters(L::Int64,
                            scv::Float64, #This is constant for all scenarios at 3.0
                            λ::Float64, #This is undefined for the scenarios since it is varied
                            η::Float64, #This is assumed constant for all scenarios at 4.0
                            μ_vector::Vector{Float64}, #service rates
                            P::Matrix{Float64}, #routing matrix
                            Q::Matrix{Float64}, #overflow matrix
                            p_e::Vector{Float64}, #external arrival distribution
                            K::Vector{Int64}) #-1 means infinity )
    L_vec = [collect(1:L) ; -1]
    P_app = [P [1-sum(P[i,:]) for i in 1:L]]
    Q_app = [Q [1-sum(Q[i,:]) for i in 1:L]]
    P_w = [Weights(P_app[i,:]) for i in 1:L]
    Q_w = [Weights(Q_app[i,:]) for i in 1:L]
    p_e_w = Weights(p_e)
    return NetworkParameters(L=L, scv=scv, λ=λ, η=η, μ_vector=μ_vector, P=P, Q=Q, p_e=p_e, K=K, L_vec=L_vec, P_w=P_w, Q_w=Q_w, p_e_w=p_e_w)
end

function gamma_scv(scv::Float64, rate::Float64)::Float64
    return rand(Gamma(1/scv, scv/rate))
end

function ext_arr_time(params::NetworkParameters)::Float64
    return gamma_scv(params.scv, params.λ)
end

function service_time(params::NetworkParameters, node::Int64)::Float64
    return gamma_scv(params.scv, params.μ_vector[node])
end

function transit_time(params::NetworkParameters)::Float64
    return gamma_scv(params.scv, params.η)
end 

function create_scen1(λ::Float64)
    return NetworkParameters( 3, 
    3.0, 
    λ, 
    4.0, 
    ones(3),
    [0 1.0 0;
    0 0 1.0;
    0 0 0],
    zeros(3,3),
    [1.0, 0, 0],
    fill(5,3))
end

function create_scen2(λ::Float64)
    return NetworkParameters(3, 
    3.0, 
    λ, 
    4.0, 
    ones(3),
    [0 1.0 0;
    0 0 1.0;
    0.5 0 0],
    zeros(3,3),
    [1.0, 0, 0],
    fill(5,3))
end

function create_scen3(λ::Float64)
    return NetworkParameters(3, 
    3.0, 
    λ, 
    4.0, 
    ones(3),
    [0 1.0 0;
    0 0 1.0;
    0.5 0 0],
    [0 0.5 0;
    0 0 0.5;
    0.5 0 0],
    [1.0, 0, 0],
    fill(5,3))
end

function create_scen4(λ::Float64)
    return NetworkParameters(5, 
    3.0, 
    λ, 
    4.0, 
    collect(5.0:-1.0:1.0),
    [0   0.5 0.5 0   0;
    0   0   0   1   0;
    0   0   0   0   1;
    0.5 0   0   0   0;
    0.2 0.2 0.2 0.2 0.2],
    [0 0 0 0 0;
    1. 0 0 0 0;
    1. 0 0 0 0;
    1. 0 0 0 0;
    1. 0 0 0 0],                             
    [0.2, 0.2, 0, 0, 0.6],
    [-1, -1, 10, 10, 10])
end

function create_scen5(λ::Float64)
    return NetworkParameters(20, 
    3.0, 
    λ, 
    4.0, 
    ones(Float64, 20),
    zeros(20,20),
    diagm(3=>0.8*ones(17), -17=>ones(3)),                        
    vcat(1,zeros(19)),
    fill(5,20))
end


function get_num_nodes(params::NetworkParameters)::Int64
    return params.L
end