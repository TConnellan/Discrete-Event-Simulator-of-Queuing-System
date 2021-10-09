
include("./src/parameters.jl")
include("./src/state.jl")
include("./src/events.jl")
include("./src/system.jl")


############################
scenario1 = NetworkParameters(  L=3, 
                                gamma_shape = 3.0, 
                                λ = NaN, 
                                η = 4.0, 
                                μ_vector = ones(3),
                                P = [0 1.0 0;
                                    0 0 1.0;
                                    0 0 0],
                                Q = zeros(3,3),
                                p_e = [1.0, 0, 0],
                                K = fill(5,3))
@show scenario1

############################
scenario2 = NetworkParameters(  L=3, 
                                gamma_shape = 3.0, 
                                λ = NaN, 
                                η = 4.0, 
                                μ_vector = ones(3),
                                P = [0 1.0 0;
                                    0 0 1.0;
                                    0.5 0 0],
                                Q = zeros(3,3),
                                p_e = [1.0, 0, 0],
                                K = fill(5,3))
@show scenario2

############################
scenario3 = NetworkParameters(  L=3, 
                                gamma_shape = 3.0, 
                                λ = NaN, 
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
@show scenario3

############################
scenario4 = NetworkParameters(  L=5, 
                                gamma_shape = 3.0, 
                                λ = NaN, 
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
@show scenario4

############################
scenario5 = NetworkParameters(  L=20, 
                                gamma_shape = 3.0, 
                                λ = NaN, 
                                η = 4.0, 
                                μ_vector = ones(20),
                                P = zeros(20,20),
                                Q = diagm(3=>ones(19), -19=>ones(3)),                             
                                p_e = vcat(1,zeros(19)),
                                K = fill(5,20))
@show scenario5
scenario1 = Main.##WeaveSandBox#263.NetworkParameters
  L: Int64 3
  gamma_shape: Float64 3.0
  λ: Float64 NaN
  η: Float64 4.0
  μ_vector: Array{Float64}((3,)) [1.0, 1.0, 1.0]
  P: Array{Float64}((3, 3)) [0.0 1.0 0.0; 0.0 0.0 1.0; 0.0 0.0 0.0]
  Q: Array{Float64}((3, 3)) [0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0]
  p_e: Array{Float64}((3,)) [1.0, 0.0, 0.0]
  K: Array{Int64}((3,)) [5, 5, 5]

scenario2 = Main.##WeaveSandBox#263.NetworkParameters
  L: Int64 3
  gamma_shape: Float64 3.0
  λ: Float64 NaN
  η: Float64 4.0
  μ_vector: Array{Float64}((3,)) [1.0, 1.0, 1.0]
  P: Array{Float64}((3, 3)) [0.0 1.0 0.0; 0.0 0.0 1.0; 0.5 0.0 0.0]
  Q: Array{Float64}((3, 3)) [0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0]
  p_e: Array{Float64}((3,)) [1.0, 0.0, 0.0]
  K: Array{Int64}((3,)) [5, 5, 5]

scenario3 = Main.##WeaveSandBox#263.NetworkParameters
  L: Int64 3
  gamma_shape: Float64 3.0
  λ: Float64 NaN
  η: Float64 4.0
  μ_vector: Array{Float64}((3,)) [1.0, 1.0, 1.0]
  P: Array{Float64}((3, 3)) [0.0 1.0 0.0; 0.0 0.0 1.0; 0.5 0.0 0.0]
  Q: Array{Float64}((3, 3)) [0.0 0.5 0.0; 0.0 0.0 0.5; 0.5 0.0 0.0]
  p_e: Array{Float64}((3,)) [1.0, 0.0, 0.0]
  K: Array{Int64}((3,)) [5, 5, 5]

scenario4 = Main.##WeaveSandBox#263.NetworkParameters
  L: Int64 5
  gamma_shape: Float64 3.0
  λ: Float64 NaN
  η: Float64 4.0
  μ_vector: Array{Float64}((5,)) [5.0, 4.0, 3.0, 2.0, 1.0]
  P: Array{Float64}((5, 5)) [0.0 0.5 … 0.0 0.0; 0.0 0.0 … 1.0 0.0; … ; 0.5 
0.0 … 0.0 0.0; 0.2 0.2 … 0.2 0.2]
  Q: Array{Float64}((5, 5)) [0.0 0.0 … 0.0 0.0; 1.0 0.0 … 0.0 0.0; … ; 1.0 
0.0 … 0.0 0.0; 1.0 0.0 … 0.0 0.0]
  p_e: Array{Float64}((5,)) [0.2, 0.2, 0.0, 0.0, 0.6]
  K: Array{Int64}((5,)) [-1, -1, 10, 10, 10]

scenario5 = Main.##WeaveSandBox#263.NetworkParameters
  L: Int64 20
  gamma_shape: Float64 3.0
  λ: Float64 NaN
  η: Float64 4.0
  μ_vector: Array{Float64}((20,)) [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 
1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  P: Array{Float64}((20, 20)) [0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0; … ; 0.
0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0]
  Q: Array{Float64}((22, 22)) [0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0; … ; 0.
0 1.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0]
  p_e: Array{Float64}((20,)) [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  K: Array{Int64}((20,)) [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
, 5, 5, 5]

Main.##WeaveSandBox#263.NetworkParameters
  L: Int64 20
  gamma_shape: Float64 3.0
  λ: Float64 NaN
  η: Float64 4.0
  μ_vector: Array{Float64}((20,)) [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 
1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  P: Array{Float64}((20, 20)) [0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0; … ; 0.
0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0]
  Q: Array{Float64}((22, 22)) [0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0; … ; 0.
0 1.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0]
  p_e: Array{Float64}((20,)) [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  K: Array{Int64}((20,)) [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
, 5, 5, 5]