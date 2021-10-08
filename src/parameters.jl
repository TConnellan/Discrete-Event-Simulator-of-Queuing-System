using Parameters #You need to install the Parameters.jl package: https://github.com/mauro3/Parameters.jl 
using LinearAlgebra 
using DataStructures

#The @with_kw macro comes from the Parameters package
@with_kw struct NetworkParameters
    L::Int
    gamma_shape::Float64 #This is constant for all scenarios at 3.0
    λ::Float64 #This is undefined for the scenarios since it is varied
    η::Float64 #This is assumed constant for all scenarios at 4.0
    μ_vector::Vector{Float64} #service rates
    P::Matrix{Float64} #routing matrix
    Q::Matrix{Float64} #overflow matrix
    p_e::Vector{Float64} #external arrival distribution
    K::Vector{Int} #-1 means infinity 
end