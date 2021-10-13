using Parameters #You need to install the Parameters.jl package: https://github.com/mauro3/Parameters.jl 
using LinearAlgebra 
using DataStructures
using Distributions

#The @with_kw macro comes from the Parameters package
@with_kw struct NetworkParameters
    L::Int
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