include("input.jl")



function Calcualte_queue_length(
    cum_ia_times::Vector{Vector{Float64}},
    cum_s_times::Vector{Vector{Float64}},
    stop_calculate_at_person_n::Int64,
    )
    """
    Calculate average queue length.
    """
    tot_queue_length = Vector{Float64}()
    for i in 1:length(cum_ia_times)
        work_ia_times = cum_ia_times[i]
        work_s_times = cum_s_times[i]
        que_length = 0
        for j in 2:stop_calculate_at_person_n
            sel_length = work_s_times[j-1] - work_ia_times[j]
            if sel_length >= 0
                que_length += sel_length
            end
        end
        push!(tot_queue_length, que_length / stop_calculate_at_person_n)
    end
    return tot_queue_length
end



function caluclate_avg_waiting_time(
    cum_ia_times::Vector{Vector{Float64}},
    cum_s_times::Vector{Vector{Float64}},
    serverBase::ServerBase,
    stop_calculate_at_person_n::Int64,
    )
    """
    Calcualte average  waiting time.
    """
    tot_waiting_time = Vector{Float64}()

    for i in 1:length(cum_ia_times)
        # Initialize the relevant data
        work_ia_times = cum_ia_times[i]
        work_s_times = cum_s_times[i]
        newServer = serverBase

        # Stating start parameters.
        sel_waiting_time = 0
        inside_que = Float64[]
        calculation_leaver_time = work_s_times[stop_calculate_at_person_n]

        process =  true

        # Define arrival and departure times.
        while process == true
            if length(work_ia_times) == 0
                arrival = Inf
            else
                arrival = work_ia_times[1]
            end
            departure = work_s_times[1]


            # If arrival is the next event happening
            if arrival < departure
                # Not busy -> no recording
                if newServer.busy == false
                    popfirst!(work_ia_times)
                    update_traffic(newServer, 1)
                # Busy -> start recording
                else
                    push!(inside_que, deepcopy(arrival))
                    popfirst!(work_ia_times)
                end
            
            # If departure happens next
            else
                # If no in queue -> no recording, set busy to false
                if length(inside_que) == 0
                    popfirst!(work_s_times)
                    update_traffic(newServer,-1)
                
                # Someone in que -> calculate waiting time and potential rest time.
                else
                    individual_que_time = departure - inside_que[1]
                    sel_waiting_time += individual_que_time
                    popfirst!(inside_que)
                    popfirst!(work_s_times)
                    if work_s_times[1] >= calculation_leaver_time || length(work_s_times) == 0
                        rest_sum = calculation_leaver_time .- inside_que
                        sel_waiting_time += sum(rest_sum)
                        process = false   
                    end

                end
            end
            if length(work_s_times) == 0 || work_s_times[1] >= stop_calculate_at_person_n
                process = false
            end
        end
        push!(tot_waiting_time, sel_waiting_time/calculation_leaver_time)
    end
    return tot_waiting_time
end