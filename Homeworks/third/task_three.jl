
arbitrary_person_que_length = 5
n_customers = 7
interarrival_times = [0.6, 0.3, 0.5, 0.2, 0.7, 0.3, 0.4]
service_times = [0.6, 0.8, 1.2, 0.6, 1.1, 0.6, 0.5]



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


function caluclate_avg_waiting_time(
    arbitrary_person_que_length::Int,
    calculate_ia_and_s_times::Function,
    ia_times::Vector{Float64}, 
    s_times::Vector{Float64},
    )
    """
    Calcualte average  waiting time that an abritrary person 
    must stand in line for
    """
    cum_ia_times, cum_s_times = calculate_ia_and_s_times(
        ia_times, s_times
        )
    
    total_waiting_time = 0
    inside_que = Float64[]
    busy = false
    calculation_leaver_time = cum_s_times[arbitrary_person_que_length]
    process =  true

    while process == true
        if length(cum_ia_times) == 0
            arrival = Inf
        else
            arrival = cum_ia_times[1]
        end
        departure = cum_s_times[1]
        
        # Continue the line
        if departure > calculation_leaver_time || length(cum_s_times) == 0
            process = false
        end

        # Arrival happens next
        if arrival < departure
            # Not busy -> no recording
            if busy == false
                popfirst!(cum_ia_times)
                busy = true
            # Busy -> start recording
            else
                push!(inside_que, deepcopy(arrival))
                popfirst!(cum_ia_times)
                busy = true
            end
        
        # Departure happens next
        else
            # If no in queue -> no recording, set busy to false
            if length(inside_que) == 0
                popfirst!(cum_s_times)
                busy = false
            
            # Someone in que -> calculate w-time and potential rest time
            else
                individual_que_time = departure - inside_que[1]
                total_waiting_time += individual_que_time
                popfirst!(inside_que)
                popfirst!(cum_s_times)
                busy = true        

                if (length(cum_s_times) >= 1) && (cum_s_times[1] > calculation_leaver_time)
                    rest_sum = calculation_leaver_time .-inside_que
                    total_waiting_time += sum(rest_sum)
                    process = false
                end
            end
        end
    end
    return  total_waiting_time/calculation_leaver_time
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

a = calculate_ia_and_s_times(interarrival_times, service_times)

b = caluclate_avg_que_length(
    arbitrary_person_que_length, 
    calculate_ia_and_s_times,
    interarrival_times,
    service_times,
    )
avg_que_value = round(b, digits=2)

c = caluclate_avg_waiting_time(
    arbitrary_person_que_length, 
    calculate_ia_and_s_times,
    interarrival_times,
    service_times,
    )
avg_wait_value = round(c, digits=2)

println("---Program start---")
println("Average queue length is: $avg_que_value.")
println("Average waiting time is: $avg_wait_value.")
println("---Program end---")