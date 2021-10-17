using Parameters #You need to install the Parameters.jl package: https://github.com/mauro3/Parameters.jl 
using LinearAlgebra 
using DataStructures
using Distributions

#The @with_kw macro comes from the Parameters package
@with_kw struct NetworkParameters
    #L::Int
    L::Vector{Int}
    scv::Float64 #This is constant for all scenarios at 3.0
    λ::Float64 #This is undefined for the scenarios since it is varied
    η::Float64 #This is assumed constant for all scenarios at 4.0
    μ_vector::Vector{Float64} #service rates
    P::Matrix{Float64} #routing matrix
    Q::Matrix{Float64} #overflow matrix
    p_e::Vector{Float64} #external arrival distribution
    K::Vector{Int} #-1 means infinity 
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
    return NetworkParameters( L=collect(1:3), 
    scv = 3.0, 
    λ = λ, 
    η = 4.0, 
    μ_vector = ones(3),
    P = [0 1.0 0;
        0 0 1.0;
        0 0 0],
    Q = zeros(3,3),
    p_e = [1.0, 0, 0],
    K = fill(5,3))
end

function create_scen2(λ::Float64)
    return NetworkParameters(  L=collect(1:3), 
    scv = 3.0, 
    λ = λ, 
    η = 4.0, 
    μ_vector = ones(3),
    P = [0 1.0 0;
        0 0 1.0;
        0.5 0 0],
    Q = zeros(3,3),
    p_e = [1.0, 0, 0],
    K = fill(5,3))
end

function create_scen3(λ::Float64)
    return NetworkParameters(  L=collect(1:3), 
    scv = 3.0, 
    λ = λ, 
    η = 4.0, 
    μ_vector = ones(3),
    P = [0 1.0 0;
        0 0 1.0;
        0.5 0 0],
    Q = [0 0.5 0;
         0 0 0.5;
         0.5 0 0],
    p_e = [1.0, 0, 0],
    K = fill(5,3))
end

function create_scen4(λ::Float64)
    return NetworkParameters(  L=collect(1:5), 
    scv = 3.0, 
    λ = λ, 
    η = 4.0, 
    μ_vector = collect(5:-1:1),
    P = [0   0.5 0.5 0   0;
         0   0   0   1   0;
         0   0   0   0   1;
         0.5 0   0   0   0;
         0.2 0.2 0.2 0.2 0.2],
    Q = [0 0 0 0 0;
         1 0 0 0 0;
         1 0 0 0 0;
         1 0 0 0 0;
         1 0 0 0 0],                             
    p_e = [0.2, 0.2, 0, 0, 0.6],
    K = [-1, -1, 10, 10, 10])
end

function create_scen5(λ::Float64)
    return NetworkParameters(  L=collect(1:20), 
    scv = 3.0, 
    λ = λ, 
    η = 4.0, 
    μ_vector = ones(20),
    P = zeros(20,20),
    Q = diagm(3=>0.8*ones(17), -17=>ones(3)),                        
    p_e = vcat(1,zeros(19)),
    K = fill(5,20))
end


function get_num_nodes(params::NetworkParameters)::Int64
    return length(params.L)
end