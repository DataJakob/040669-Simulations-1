# System for simulating a queue. 
The system is being developed continouously, and gets new functionality added based on homeworks.

## Functionality:
Distribution_Generator(a,b,c,d,e,f,g)\
a: string, Distribution type\
b: float, mean of distribution\
c: float, sigma of distribution (0 if None)\
d: int, number of arrivers in the queue\
e: int, number of queues in system\
f: float, constant for time calculations\
g: int, random seed

ServerBase(a,b)\
a: int, number of servers in system\
b: int, overload limit, arrivers goes to other queues

Data_to_json(a,b,c)\
a: vector, arrival times\
b: vector{}, service times\
c: vector{}, cumulative interarrival times

Calculate_avg_waiting_time(a,b)\
a: Server, server structure\
b: float, time for when to stop queue calculations.


## Example usage:
println("----------------------Start-----------------------")

n_lines = 1\
n_packages = 6\
n_servers_per_line = 1 \
n_packages_queue_overload = 3 

service_my = 0.7\
service_sigma = 0.01\
service_constant = 0.2

interarrival_my = 1.0\
interarrival_sigma = 0.6\
interarrival_constant = 0.5

stop_calculate_paratmeres_at_person_n = 5



arrival_times = Distribution_Generator("Normal", interarrival_my, interarrival_sigma, \
    n_packages, n_lines , interarrival_constant, 42)\
service_times = Distribution_Generator("Normal", service_my, service_sigma,\
    n_packages, n_lines, service_constant, 1000)\
cum_ia_times = Calculate_cum_ia_times(arrival_times)\
my_server = ServerBase(n_servers_per_line, n_packages_queue_overload)

Data_to_json(arrival_times, service_times, cum_ia_times)\
Run_the_queue(my_server, Inf64)\
wait_time, que_length = Calculate_key_parameters(stop_calculate_paratmeres_at_person_n)\
println("Average waiting time: ", wait_time)\
println("Average queue length: ", que_length)\
println("----------------------End-----------------------")

## Possibilities
| n queues | n servers | special functionality                    | Possible|
|----------|-----------|----------------------                    |---------|
| 1        | 1         |                                          | ✅      |
| 1        | n         |                                          | ✅      |
| n        | n->1      |                                          | ✅      |
| n        | n->n      |                                          | ✅      |
|          |           |  Change server queue when queue too long | ✅      |
|          |           |  Leave queue after time x                | ❌      |
|          |           |  Calculate avg. queue length             | ✅      |
|          |           |  Calculate acg. waiting time             | ✅      |


