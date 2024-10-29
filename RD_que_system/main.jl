println("-----")

include("src/00_arriver.jl")
include("src/01_server.jl")
include("src/calc_simultanously.jl")


arrival_times = Distribution_Generator("Normal", 0.5, 0.3, 6, 1, 0.2, 42)
service_times = Distribution_Generator("Normal", 1.0, 0.6, 6, 1, 0.0, 1000)
cum_ia_times = Calculate_cum_ia_times(arrival_times)
my_server = ServerBase(2,2)

Data_to_json(arrival_times, service_times, cum_ia_times)

Caluclate_avg_waiting_time(my_server,4.0)

println("-----")
