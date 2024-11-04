println("START-----")
println("----")
println("---")
println("--")
println("-")

include("src/00_arriver.jl")
include("src/01_server.jl")
include("src/02_run_queue.jl")
include("src/03_calculate_parameters.jl")


arrival_times = Distribution_Generator("Normal", 0.7, 0.01, 6, 1, 0.2, 42)
service_times = Distribution_Generator("Normal", 1.0, 0.6, 6, 1, 0.5, 1000)
cum_ia_times = Calculate_cum_ia_times(arrival_times)
my_server = ServerBase(1,3)

Data_to_json(arrival_times, service_times, cum_ia_times)
Run_the_queue(my_server, 78.0)
wait_time, que_length = Calculate_key_parameters(5)
println("Average waiting time: ", wait_time)
println("Average queue length: ", que_length)

println("-")
println("--")
println("---")
println("----")
println("-----END")
# myServer.current_queue