

function Calculate_key_parameters(end_at_person::Int64)

    file_path = "RD_que_system/data/final_output.json"
    data = open(file_path, "r") do file
        JSON.parse(file)
    end


    # Calculate waiting time for n queues
    waiting_time_total = Vector{Float64}()
    for i in 1:length(data)
        wait_queue =  0.0
        for j in 1:end_at_person
            wait_queue += data[i][j]["w_time"]
        end
        push!(waiting_time_total, deepcopy(wait_queue)/end_at_person)
    end

    # Calculate queue length time for n queues
    queue_length_total = Vector{Float64}()
    for i in 1:length(data)
        que_length = 0.0
        break_time = data[i][end_at_person]["dep_time"]
        for j in 1:length(data[i])
            if data[i][j]["dep_time"] - data[i][j]["s_time"] > break_time
                w_n = break_time - data[i][j]["cum_ia_time"] < 0 ? 0 : break_time - data[i][j]["cum_ia_time"]
            else
                w_n = data[i][j]["w_time"]
            end
            que_length  += w_n
        end
        push!(queue_length_total, deepcopy(que_length) / break_time)
    end

    return (waiting_time_total, queue_length_total)
end
