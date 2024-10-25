

include("src/input.jl")
include("src/calculations.jl")


# # Example distributions
# arrival_times = [[0.6, 0.3, 0.5, 0.2, 0.7, 0.3, 0.4]]
# service_times = [[0.6, 0.8, 1.2, 0.6, 1.1, 0.6, 0.5]]



println("----------------------Start-----------------------")
# Dist_type, mean, sigma, n_arrivers, n_arrays, cons, random_seed
arrival_times = Distribution_Generator("Normal", 0.5, 0.5, 6, 1, 1.0, 42)
service_times = Distribution_Generator("Normal", 1.0, 0.6, 6, 1, 0.0, 1000)
cum_ia_times, cum_s_times = Calculate_ia_and_s_times(arrival_times, service_times)

# set n_servers, set 0 traffic, set busy to false, stop at person n
myServer = ServerBase(1,0,false)

# cum_ia_times, cum_s_times, stop at person n
avg_que = Calcualte_queue_length(cum_ia_times,cum_s_times, 5)

# cum_ia_times, cum_s_times, server, stop at person n
avg_wait = caluclate_avg_waiting_time(cum_ia_times, cum_s_times,  myServer, 6)

println("avg queue length: ",avg_que)
println("avg wait time: ", avg_wait)
println("----------------------End-----------------------")
