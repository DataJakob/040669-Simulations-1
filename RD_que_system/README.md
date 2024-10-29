# System for simulating a queue. 
The system is being developed continouously, and gets new functionality added based on homeworks.

## Functionality:
Distribution_Generator(a,b,c,d,e,f,g)
a: string, Distribution type
b: float, mean of distribution
c: float, sigma of distribution (0 if None)
d: int, number of arrivers in the queue
e: int, number of queues in system
f: float, constant for time calculations
g: int, random seed.

ServerBase(a,b)
a: int, number of servers in system
b: int, overload limit, arrivers goes to other queues

Data_to_json(a,b,c)
a: vector, arrival times
b: vector{}, service times
c: vector{}, cumulative interarrival times

Calculate_avg_waiting_time(a,b)
a: Server, server structure
b: float, time for when to stop queue calculations. 


## Example usage:
println("----------------------Start-----------------------")

arrival_times = Distribution_Generator("Normal", 0.5, 0.3, 6, 1, 0.2, 42)
service_times = Distribution_Generator("Normal", 1.0, 0.6, 6, 1, 0.0, 1000)
cum_ia_times = Calculate_cum_ia_times(arrival_times)
my_server = ServerBase(2,2)

Data_to_json(arrival_times, service_times, cum_ia_times)

Caluclate_avg_waiting_time(my_server,4.0)

println("----------------------End-----------------------")

## Possibilities
| n queues | n servers | special functionality | Possible   |
|----------|-----------|---------------------- |------------|
| 1        | 1         |                                         | ✅         |
| 1        | n         |                                         | ✅         |
| n        | n         |                                         | ✅         |
|         |           |  Change server queue when queue too long | ✅        |
|         |           |  Leave queue after time x                | ❌         |
|         |           |  Calculate avg. queue length             |      🔜     |
|         |           |  Calculate acg. waiting time             |       🔜      |


