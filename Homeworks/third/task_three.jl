
# mutable struct Server
#     Busy::Bool
# end
# n_servers = 2


arbitrary_person_que_length = 5
n_customers = 7
interarrival_times = [0.6, 0.3, 0.5, 0.2, 0.7, 0.3, 0.4]
service_times = [0.6, 0.8, 1.2, 0.6, 1.1, 0.6, 0.5]


# function server_generator(n_servers::Int)
#     server_dict = Dict()
#     for i in 1:n_servers
#         server_id = "server$i"
#         server_qual = Server(false)
#         server_dict[server_id] = server_qual
#     end
#     println("--Servers has been generated")
#     return server_dict
# end


function calculate_ia_and_s_times(
    ia_times::Vector{Float64}, 
    s_times::Vector{Float64}
    )
    """ 
    Calculate the cumulative times for 
    interarrival and serivces.
    """
    cum_ia_times = [deepcopy(ia_times[1])]
    cum_s_times = [deepcopy(s_times[1]+ia_times[1])]

    for i in 2:length(ia_times)
        push!(cum_ia_times, deepcopy(ia_times[i] + cum_ia_times[i-1]))
        alt_1 = cum_s_times[i-1] + s_times[i]
        alt_2 = cum_ia_times[i] + s_times[i]
        relevant_time = max(alt_1, alt_2)
        push!(cum_s_times, relevant_time)
    end    
    return [cum_ia_times, cum_s_times]
end


function calculata_avg_wait_time(
    calculate_ia_and_s_times::Function,
    ia_times::Vector{Float64}, 
    s_times::Vector{Float64},
    n_customers::Int64,
    arbitrary_person_que_length::Int,
    )
    """
    Calcualte average  waiting time that an abritrary person 
    must stand in line for
    """
    cum_ia_times, cum_s_times = calculate_ia_and_s_times(
        ia_times, s_times
        )
    waiting_time = 0
    for i in 1:length(cum_s_times)
        waiting_time += (cum_s_times[i] -s_times[i] - cum_ia_times[i])
    end
    return  waiting_time/n_customers
end



function caluclate_avg_que_length(
    arbitrary_person_que_length::Int64,
    calculate_ia_and_s_times::Function,
    ia_times::Vector{Float64},
    s_times::Vector{Float64}
    )
    """
    Calcualte average queue length until a person leaves the queue.
    """
    cum_ia_times, cum_s_times = calculate_ia_and_s_times(
        ia_times, s_times
        )
    que_length = 0
    for i in 2:arbitrary_person_que_length
        sel_length = cum_s_times[i-1] - cum_ia_times[i]
        if sel_length >= 0
            que_length += sel_length
        end
    end
    return que_length / arbitrary_person_que_length
end

# a = server_generator(n_servers)
b = calculate_ia_and_s_times(interarrival_times, service_times)
# c = calculata_avg_wait_time(calculate_ia_and_s_times,
#     interarrival_times,
#     service_times,
#     n_customers,
# )

# d = caluclate_avg_que_length(
#     arbitrary_person_que_length, 
#     calculate_ia_and_s_times,
#     interarrival_times,
#     service_times,
#     )
# avg_que_value = round(d, digits=2)

# println("---Program start---")
# println("Average queue length is: $avg_que_value.")
# println("---Program end---")