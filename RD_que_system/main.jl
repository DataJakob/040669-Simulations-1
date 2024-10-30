println("-----")

include("src/00_arriver.jl")
include("src/01_server.jl")
include("src/02_calc_simultanously.jl")


arrival_times = Distribution_Generator("Normal", 0.7, 0.01, 6, 1, 0.2, 42)
service_times = Distribution_Generator("Normal", 1.0, 0.6, 6, 1, 0.5, 1000)
cum_ia_times = Calculate_cum_ia_times(arrival_times)
my_server = ServerBase(1,3)

Data_to_json(arrival_times, service_times, cum_ia_times)
Run_the_queue(my_server, 78.0)


println("-----")
# myServer.current_queue