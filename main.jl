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

    # with these ranges 10^5 ran in ~36s on toms pc, expect 10^7 to take 60mins
    scen == 1 && return ([collect(0.01:0.01:1.) ; collect(1.1:0.1:10) ;15 ;20], [0.1, 0.5, 1.5, 3, 10])

    # with these ranges 10^5 ran in ~40s on toms pc, expect 10^7 to take 66mins
    scen == 2 && return ([collect(0.01:0.01:1.) ; collect(1.1:0.1:10) ;15 ;20], [0.1, 0.5, 1.5, 3, 10]) 

    # with these ranges 10^5 ran in ~25s on toms pc, expect 10^7 to take 41mins
    scen == 3 && return ([collect(0.01:0.01:1.) ; collect(1.1:0.1:10) ;15 ;20], [0.1, 0.5, 1.5, 3, 10])

    # with these ranges 10^5 ran in ~65s, expect 10^7 to take 108mins
    # this takes the longest but there are interesting features that are captured with these ranges of values
    # hard to do sojourn plot with these values without using log scale on the x-axis
    # log-scale on y-acis of first plot makes it look clearer too
    scen == 4 && return (collect(0.75:0.01:1.1), [0.01, 0.25, 0.5, .75, .85, .9])

    # with these ranges 10^5 ran in ~30s, expect 10^7 to take 50mins
    # hard to do sojourn plot with these values without using log scale on the x-axis
    scen == 5 && return (collect(.01:.01:3), [0.1, 0.5, 2, 5, 10])
    throw("no such scenario specificied")
end

function get_lims(scen::Int64)
    scen == 1 && return [:auto, 40]
    scen == 2 && return [:auto, 80]
    scen == 3 && return [:auto, 100]
    scen == 4 && return [:auto, 300]
    scen == 5 && return [:auto, 25]
end

function get_plots(scenario::Int64, time::Float64; save::String="test")
    t = floor(Int, log10(time))
    plot12_vals, plot3_vals = get_ranges(scenario)

    scens = [create_scen1, create_scen2, create_scen3, create_scen4, create_scen5]
    Λ, means, props, soj_Λ, sojourns = collect_data(scens[scenario], plot12_vals, plot3_vals, time)
    means_plot = plot(Λ, means, legend=false,
                        yscale= scenario == -4 ? :log10 : :identity,
                        xlabel="Rate of arrival λ", 
                        ylabel="Mean number of items",
                        title="The mean number of items in the system as\n λ varies with a time horizon of T=10^$t")
    
    savefig(means_plot, ".//$(save)plots//scen$(scenario)//scen$(scenario)_means_plot.png")
    
    props_plot = plot(Λ, props, legend=false,
                        xlabel="Rate of arrival λ", 
                        ylabel="Proportion in transit",
                        title="The proportion of items in orbit\nas λ varies with a time horizon of T=10^$t")
    
    savefig(props_plot, ".//$(save)plots//scen$(scenario)//scen$(scenario)_props_plot")

    x_scale = get_lims(scenario)

    ecdf_plot = plot_emp(soj_Λ,sojourns, xlims = x_scale,
                            legend = :bottomright,
                            title="ECDF's of the sojourn time of an item\n for varied λ with a time horizon of T=10^$t\n",
                            xlabel_log = "")
    savefig(ecdf_plot, ".//$(save)plots//scen$(scenario)//scen$(scenario)_sojourn_plot")
end


function create_all_plots(time::Float64; save::String="test")
    for i in 1:5
        println("scenario $i")
        @time get_plots(i, time, save=save)
    end
end