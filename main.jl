using Distributions
using StatsBase
using TimerOutputs

include("./src/parameters.jl")
include("./src/state.jl")
include("./src/events.jl")
include("./src/system.jl")
include("./src/routing_functions.jl")




# scenario 1
# collect_data(create_scen1, 0.01, 0.01, 3, 1e4) runs in ~12s on my prev_count
# as we increase the time horizon by a factor of 10, the runtime increase by about a factor of 10
# so i think I could run collect_data(create_scen1, 0.01, 0.01, 3, 1e7) in 3-4 hours

# scenario 2


# scenario 3

# scenario 4 , λ from 0 to 1, with larger λ more and more jobs accumulate at the first node, plot 1 begins to diverge and plot 2 converges to 0
# may have to use log scale on the y-axis

# scenario 5



#function collect_data(scenario, start, step, fin, soj_start, soj_step, soj_fin, time)
function collect_data(scenario, plot12_vals, plot3_vals, time)


    Λ = plot12_vals
    soj_Λ = plot3_vals
    means = Vector{Float64}(undef, length(Λ))
    props = Vector{Float64}(undef, length(Λ))
    sojourns = Vector{Vector{Float64}}(undef, length(soj_Λ))

    @inbounds for (i, λ) in enumerate(Λ)
        means[i], props[i] = run_sim(TrackTotals, scenario, λ=λ, max_time = time)
    end
    @inbounds for (i,λ) in enumerate(soj_Λ)
        sojourns[i] = run_sim(TrackAllJobs, scenario, λ=λ, max_time=time)
    end

    return Λ, means, props, soj_Λ, sojourns
end

function get_ranges(scen::Int64)
    # first array is λ values for first 2 plots
    # second array are values for third plot

    # runtime for get_plots() appears to be O(t) where t is the max_time 

    # with these ranges 10^5 ran in ~45s on toms pc, expect 10^7 to take 75mins
    scen == 1 && return (collect(0.01:0.01:3), [0.1, 0.25, 0.5, 1, 1.5, 2, 3, 5, 10, 20])

    # with these ranges 10^5 ran in ~50s on toms pc, expect 10^7 to take 83mins
    scen == 2 && return (collect(0.01:0.01:3), [0.1, 0.25, 0.5, 1, 1.5, 2, 3, 5, 10, 20])

    # with these ranges 10^5 ran in ~30s on toms pc, expect 10^7 to take 50mins
    scen == 3 && return (collect(0.01:0.05:5), [0.1, 0.5, 1, 1.5, 2, 3, 5, 10])

    # with these ranges 10^5 ran in ~75s, expect 10^7 to take 125mins
    # this takes the longest but there are interesting features that are captured with these ranges of values
    scen == 4 && return (collect(0.01:0.015:1.5), [0.1, 0.5, 0.85, 1, 2, 3, 5, 7, 10])

    # with these ranges 10^5 ran in ~40s, expect 10^7 to take 66mins
    scen == 5 && return (collect(.01:.01:3), [.1, .5, 1, 5, 10, 20])
    throw("no such scenario specificied")
end


function get_plots(scenario::Int64, time::Float64; save::String="test")
    t = floor(Int, log10(time))
    plot12_vals, plot3_vals = get_ranges(scenario)

    scens = [create_scen1, create_scen2, create_scen3, create_scen4, create_scen5]
    Λ, means, props, soj_Λ, sojourns = collect_data(scens[scenario], plot12_vals, plot3_vals, time)
    means_plot = plot(Λ, means, legend=false,
                        yscale= scenario == 4 ? :log10 : :identity,
                        xlabel="Rate of arrival λ", 
                        ylabel="Mean number of items$(scenario == 4 ? " (log_10)" : "")",
                        title="The mean number of items in the system as\nrate of arrival (λ) varies during\nscenario $scenario with a runtime of T=10^$t.")
    
    savefig(means_plot, ".//$(save)plots//scen$(scenario)//scen$(scenario)_means_plot.png")
    
    props_plot = plot(Λ, props, legend=false,
                        xlabel="Rate of arrival λ", 
                        ylabel="Proportion in transit",
                        title="The proportion of items in transit against\nthe number of items in the total system\nas rate of arrival (λ) varies\nduring scenario $scenario with a runtime of T=10^$t.")
    
    savefig(props_plot, ".//$(save)plots//scen$(scenario)//scen$(scenario)_props_plot")

    ecdf_plot = plot_emp(soj_Λ,sojourns, xscale = scenario == 4 || scenario == 5 ? :log10 : :identity, xlims = scenario == 4 || scenario == 5 ? [0.01, :auto] : [:auto, :auto],
                            legend = scenario ==4 ? :topleft : :bottomright,
                            title="Empirical cumulative distribution functions of the sojourn\ntime of an item for varied rates of arrival (λ) during\nscenario $scenario with a runtime of T=10^$t\n",
                            xlabel_log = scenario == 4 || scenario == 5 ? " (log_10)" : "")
    savefig(ecdf_plot, ".//$(save)plots//scen$(scenario)//scen$(scenario)_sojourn_plot")
end


function create_all_plots(time::Float64; save::String="test")
    for i in 1:5
        println("scenario $i")
        @time get_plots(i, time, save=save)
    end
end