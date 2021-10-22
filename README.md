# MATH2504 - Project 2

## Marco Maggiore & Thomas Connellan

[Assignment Instructions](https://courses.smp.uq.edu.au/MATH2504/assessment_html/project2.html)

A discrete event simulator for a finite item-station-service system in continous time

Simulate and create/save plots based on the predefined scenarios by running main.jl and then calling the create_all_plots(t, save="") where t is your
desired time-horizon as a float. This requires a pre-existing folder structure of
plots  
&nbsp;&nbsp;&nbsp;&nbsp;scen1  
&nbsp;&nbsp;&nbsp;&nbsp;scen2  
&nbsp;&nbsp;&nbsp;&nbsp;scen3  
&nbsp;&nbsp;&nbsp;&nbsp;scen4  
&nbsp;&nbsp;&nbsp;&nbsp;scen5  

If you wish to run for a new scenario then you will need to specify a function (of lambda) to create the parameter struct
and call collect_data(scenario_function, lambda_vals1, lambda_vals2, time) where lambda_vals1 are the values of which you wish
to compute the average time of an item in the system and proportion of jobs in orbit, and lambda_vals2 are the values of wish you wish to 
find the sojourn times of jobs in the system. This will give you the data after which you utilise the inbuilt plot() and provided plot_emp()
to create graphs as you see fit.

If you wish to use the provided create_all_plots function for your own scenarios then you will need to modify the get_ranges() and get_lims()
functions appropriately as well as adding a new folder inside the plots folder.