

using JSON
include("01_server.jl")
include("00_arriver.jl")


function Find_datapoint_in_json(id::String)
    first_index = Char(id[1]) - 'a' + 1
    second_index = parse(Int, id[2:end])
    return (first_index, second_index)
end


function Find_datapoint_in_server(dict_vector::Vector{ServerBase}, id::String)
    for i in 1:length(dict_vector)
        for j in 1:length(dict_vector[i].current_traffic)
            if dict_vector[i].current_traffic[j]["id"] == id
                return (i,j)
                break
            end
        end
    end
end




# Suggestion:
#   Find next event
#   Next event is arrival
#   Next event is departure

function Run_the_queue(
    server_base::ServerBase,
    stop_at_time::Float64,
    )

    # Initialize servers
    server_list = Vector{ServerBase}()
    for i in 1:length(cum_ia_times)
        push!(server_list, deepcopy(server_base))
    end

    # Create two dataframes -> one for iterating and one for storing data. 
    file_path = "RD_que_system/data/output.json"
    data = open(file_path, "r") do file
        JSON.parse(file)
    end
    data_to_be_reduced = deepcopy(data)
    
    # Break statement -> break if there is no data to be processed
    process = true
    process_end_at_end = true
    bitch = 0
    while process == true
        bitch +=1
        if length(data_to_be_reduced[1]) == 0  && (length(server_list[1].current_traffic) + length(server_list[1].current_queue)) == 1
            process = false
            process_end_at_end = false
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
            "type"=> "departure")
        push!(keys, "final_line")
        for i in 1:length(server_list)
            for j in 1:length(server_list[i].current_traffic)
                if isempty(server_list[i].current_traffic[j])
                    nothing
                else
                    bravo = server_list[i].current_traffic[j]
                    dep_time = bravo["cum_ia_time"] + bravo["s_time"] + bravo["w_time"]
                    if dep_time < next_departure["cum_ia_time"]
                        bravo_upd = Dict(k=> bravo[k] for k in keys if haskey(bravo,k))
                        merge!(next_departure, deepcopy(bravo_upd)) 
                    end
                end
            end
        end




        # Break statement -> break if next event is past stopping time
        if next_departure["id"] != nothing
            server_idx, server_nr = Find_datapoint_in_server(server_list, next_departure["id"])
            next_departure_time = server_list[server_idx].current_traffic[server_nr]["cum_ia_time"] +
                server_list[server_idx].current_traffic[server_nr]["s_time"] + 
                server_list[server_idx].current_traffic[server_nr]["w_time"]
            lowest = min(isempty(next_arriver["cum_ia_time"]) ? Inf : next_arriver["cum_ia_time"],
                next_departure_time)
            if lowest > stop_at_time
                process = false
                break
            end
        end




        # State next departure time
        if !@isdefined next_departure_time
            next_departure_time = Inf
        end 

        # If next event is arrival
        if next_arriver["cum_ia_time"] < next_departure_time
            data_x, data_y = Find_datapoint_in_json(next_arriver["id"])

            # If server overload -> search for servers that's not overloaded
            if check_busy(server_list[next_arriver["initial_line"]])
                server_idx = 0
                for i in 1:length(server_list)
                    if length(server_list[i].current_queue) < server_base.queue_overload
                        server_idx = i
                        break
                    end
                end
            end

            # If server not overload -> set package in traffic or queue
            # Decide server number
            if !@isdefined server_idx
                server_idx = next_arriver["initial_line"]
            end    
            data[data_x][data_y]["final_line"] = server_idx 

            # Server is not busy -> set pacakge in traffic, no w_time
            if check_busy(server_list[server_idx]) == false
                data[data_x][data_y]["w_time"] = 0.0
                update_traffic(server_list[server_idx],
                    true, data[data_x][data_y])
            # Server is busy-> set package in queue
            else
                update_queue(server_list[server_idx], 
                    true, data[data_x][data_y])
            end

            # Delete the item from data_to_be_reduced
            popfirst!(data_to_be_reduced[data_x])        




        # Departure is next event
        else
            data_x, data_y = Find_datapoint_in_json(next_departure["id"])

            # Identify server where next event is occuring
            server_idx, server_nr = Find_datapoint_in_server(server_list, next_departure["id"])
            
            # Setting the identified variables
            current_server = server_list[server_idx]
            datapoint = current_server.current_traffic[server_nr]

            # Fill in values for waiting time and final server line for the event.
            data[data_x][data_y]["final_line"] = datapoint["final_line"]
            data[data_x][data_y]["w_time"] = datapoint["w_time"] 
            data[data_x][data_y]["dep_time"] = datapoint["cum_ia_time"] +
                datapoint["w_time"] + datapoint["s_time"]


            # If server is busy -> 
                # Calculate waiting time for first element in queue
                # Push that element into queue.
                # Pop the departure from traffic
                # Update the json data with new information
            if check_busy(server_list[server_idx]) == true

                # Server busy, and queue equals true
                if length(current_server.current_queue) != 0
                    wait_time_for_next = datapoint["cum_ia_time"] + 
                        datapoint["w_time"] + datapoint["s_time"] -
                        current_server.current_queue[1]["cum_ia_time"]

                    current_server.current_queue[1]["w_time"]  = wait_time_for_next

                    update_traffic(current_server, false, 
                        current_server.current_traffic[server_nr])
                    update_traffic(current_server,true,
                        current_server.current_queue[1])
                    update_queue(current_server, false,
                        current_server.current_queue[1])
                # Server busy, but no queue
                else
                    update_traffic(current_server, false, 
                        current_server.current_traffic[server_nr])  
                end   
            
            # If server is not busy -> pop first element in traffic
            else
                update_traffic(current_server, false,
                    current_server.current_traffic[server_nr])
            end
        process = process_end_at_end
        end
    end
    # Save and store the data to a json with all values filled in.
    data = data
    json_string = JSON.json(data)
    open("RD_que_system/data/final_output.json", "w") do file
        write(file, json_string)
    end
end