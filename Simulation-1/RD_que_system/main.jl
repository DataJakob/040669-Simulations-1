println("--------------START--------------")

include("src/00_arriver.jl")
include("src/01_server.jl")
include("src/02_run_queue.jl")
include("src/03_calculate_parameters.jl")

n_lines = 1
n_packages = 6
n_servers_per_line = 1 
n_packages_queue_overload = 3 

service_my = 0.7
service_sigma = 0.01
service_constant = 0.2

interarrival_my = 1.0
interarrival_sigma = 0.6
interarrival_constant = 0.5

stop_calculate_paratmeres_at_person_n = 5

arrival_times = Distribution_Generator("Normal", interarrival_my, interarrival_sigma, 
    n_packages, n_lines , interarrival_constant, 42)
service_times = Distribution_Generator("Normal", service_my, service_sigma,
    n_packages, n_lines, service_constant, 1000)
cum_ia_times = Calculate_cum_ia_times(arrival_times)
my_server = ServerBase(n_servers_per_line, n_packages_queue_overload)

Data_to_json(arrival_times, service_times, cum_ia_times)

Run_the_queue(my_server, Inf64)
wait_time, que_length = Calculate_key_parameters(stop_calculate_paratmeres_at_person_n)
println("Average waiting time: ", wait_time)
println("Average queue length: ", que_length)

println("--------------END--------------")