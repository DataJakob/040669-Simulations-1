# Initialize all servers first. 
using JSON
include("01_server.jl")
include("00_arriver.jl")

function Caluclate_avg_waiting_time(
    server_base::ServerBase,
    stop_at_time::Float64,
    )

    # Initialize all necessary starting variables
    server_list = Vector{ServerBase}()
    for i in 1:length(cum_ia_times)
        push!(server_list, deepcopy(server_base))
    end


    file_path = "output.json"
    data = open(file_path, "r") do file
        JSON.parse(file)
    end
    data_to_be_reduced = deepcopy(data)
    
    function Find_Datapoint(id::String)
        first_index = Char(id[1]) - 'a' + 1
        second_index = parse(Int, id[2:end])
        return (first_index, second_index)
    end

    function find_index_by_id(dict_vector::Vector{ServerBase}, id::String)
        for i in 1:length(dict_vector)
            if dict_vector[i].current_traffic[1]["id"] == id
                return i  
                break
            end
        end
    end

    process = true
    while process == true
        if length(data_to_be_reduced) == 0
            process = false
            break        
        end

        # Check which event happens next
        keys = ["id", "initial_line", "cum_ia_time"]
        next_arriver = Dict(
            "id"=> nothing,
            "initial_line"=>nothing, 
            "cum_ia_time"=>Inf,
            "type"=>"arrival",)
        # Check arrivers
        for i in 1:length(data_to_be_reduced)  
            if i <= length(data_to_be_reduced) && !isempty(data_to_be_reduced[i]) && !isempty(data_to_be_reduced[i][1])
                alfa = data_to_be_reduced[i][1]
                if data_to_be_reduced[i][1]["cum_ia_time"] < next_arriver["cum_ia_time"]
                    alfa_upd = Dict(k=> alfa[k] for k in keys if haskey(alfa,k))
                    merge!(next_arriver, deepcopy(alfa_upd))
                end
            end
        end
        # Check departures
        next_departure = Dict(
            "id"=> nothing,
            "initial_line"=>nothing, 
            "cum_ia_time"=>Inf,
            # "final_line"=>nothing,
            "type"=> "departure")
        push!(keys, "final_line")
        for i in 1:length(server_list)
            if isempty(server_list[i].current_traffic)
                nothing
            else
                bravo = server_list[i].current_traffic[1]
                dep_time = bravo["cum_ia_time"]+bravo["s_time"]+bravo["w_time"]
                if dep_time < next_departure["cum_ia_time"]
                    bravo_upd = Dict(k=> bravo[k] for k in keys if haskey(bravo,k))
                    merge!(next_departure, deepcopy(bravo_upd))            
                end
            end
        end
        println(next_arriver)
        println(next_departure["id"])
        if next_departure["id"] != nothing
            fox = find_index_by_id(server_list, next_departure["id"])
            println(fox)
            println(server_list[fox])
            # println(server_list)
            beta = server_list[fox].current_traffic[1]["cum_ia_time"] + server_list[fox].current_traffic[1]["s_time"]+ server_list[fox].current_traffic[1]["w_time"]
            
            lowest = min(isempty(next_arriver["cum_ia_time"]) ? Inf : next_arriver["cum_ia_time"],
                beta)
            if lowest > stop_at_time
                process = false
                break
            end
        end



        # Next event is arrival
        if next_arriver["cum_ia_time"] < next_departure["cum_ia_time"]
            data_x, data_y = Find_Datapoint(next_arriver["id"])

            # If server overload -> search for first not overload
            if length(server_list[next_arriver["initial_line"]].current_queue) >= server_base.queue_overload
                server_idx = 0
                for i in 1:length(server_list)
                    if length(server_list[i].current_queue) < server_base.queue_overload
                        server_idx = i
                        break
                    end
                end

            # If server not overload -> set in traffic or queue
            else
                if !@isdefined server_idx
                    server_idx = next_arriver["initial_line"]
                end    

                data_to_be_reduced[data_x][1]["final_line"] = server_idx  

                # No busy -> set in traffic, no w_time
                if check_busy(server_list[server_idx]) == false
                    data_to_be_reduced[data_x][1]["w_time"] = 0.0
                    push!(server_list[server_idx].current_traffic, 
                        deepcopy(data_to_be_reduced[data_x][1]))

                # Busy -> set in que
                else
                    push!(server_list[server_idx].current_queue, 
                        deepcopy(data_to_be_reduced[data_x][1]))
                end
            end
            # Delete the item from data_to_be_reduced
            popfirst!(data_to_be_reduced[data_x])
        
        # Departure is next event
        else
            data_x, data_y = Find_Datapoint(next_departure["id"])

            # find id in next_departure -> find which server who has this id in current_traffic
            myid = find_index_by_id(server_list, next_departure["id"])


            if isempty(server_list[myid].current_traffic[1])
                data[data_x][data_y]["final_line"] = next_departure["final_line"]
                data[data_x][data_y]["w_time"] = 0
            else
                datapoint = server_list[myid].current_traffic[1]
                data[data_x][data_y]["final_line"] = datapoint["final_line"]
                data[data_x][data_y]["w_time"] = datapoint["w_time"]
            end
            # If que is true -> calc w, push, pop, update
            if check_busy(server_list[myid]) == true
                wait_time_for_next = datapoint["cum_ia_time"]+
                    datapoint["w_time"]+datapoint["s_time"]-
                    server_list[next_departure["final_line"]].current_queue[1]["cum_ia_time"]            
                server_list[next_departure["final_line"]].current_queue[1]["w_time"] = wait_time_for_next
                update_traffic(serverlist[next_departure["final_line"]],true,
                    server_list[next_departure["final_line"]].current_queue[1])
                update_queue(server_list[next_departure["final_line"]], false,
                    server_list[next_departure["final_line"]].current_traffic[1])
            
            # No queue -> pop traffic
            else
                update_traffic(server_list[myid], false,
                    server_list[myid].current_traffic[1])
            end
        end
    end
    json_string = JSON.json(data)
    open("final_output.json", "w") do file
        write(file, json_string)
    end
end